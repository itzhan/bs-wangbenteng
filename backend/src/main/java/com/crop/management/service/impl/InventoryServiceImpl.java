package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.dto.InventoryOperationDTO;
import com.crop.management.entity.AgriculturalMaterial;
import com.crop.management.entity.Inventory;
import com.crop.management.entity.InventoryRecord;
import com.crop.management.entity.User;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.AgriculturalMaterialMapper;
import com.crop.management.mapper.InventoryMapper;
import com.crop.management.mapper.InventoryRecordMapper;
import com.crop.management.mapper.UserMapper;
import com.crop.management.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final InventoryMapper inventoryMapper;
    private final InventoryRecordMapper inventoryRecordMapper;
    private final AgriculturalMaterialMapper agriculturalMaterialMapper;
    private final UserMapper userMapper;

    @Override
    public PageResult<Inventory> list(Integer page, Integer size, Long materialId) {
        Page<Inventory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(materialId != null, Inventory::getMaterialId, materialId);
        wrapper.orderByDesc(Inventory::getUpdateTime);
        Page<Inventory> result = inventoryMapper.selectPage(pageParam, wrapper);
        fillInventoryDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public Inventory getByMaterialId(Long materialId) {
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Inventory::getMaterialId, materialId);
        return inventoryMapper.selectOne(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void operate(InventoryOperationDTO dto, Long userId) {
        // 查找或创建库存记录
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Inventory::getMaterialId, dto.getMaterialId());
        Inventory inventory = inventoryMapper.selectOne(wrapper);

        if (inventory == null) {
            // 第一次入库，自动创建库存记录
            if (dto.getType() != 1) {
                throw new BusinessException("该农资尚未入库，请先进行入库操作");
            }
            inventory = new Inventory();
            inventory.setMaterialId(dto.getMaterialId());
            inventory.setQuantity(dto.getQuantity());
            inventory.setWarningThreshold(BigDecimal.TEN); // 默认预警阈值
            inventoryMapper.insert(inventory);
        } else {
            if (dto.getType() == 1) {
                // 入库：增加库存
                inventory.setQuantity(inventory.getQuantity().add(dto.getQuantity()));
            } else if (dto.getType() == 2) {
                // 出库：减少库存
                if (inventory.getQuantity().compareTo(dto.getQuantity()) < 0) {
                    throw new BusinessException("库存不足，当前库存：" + inventory.getQuantity());
                }
                inventory.setQuantity(inventory.getQuantity().subtract(dto.getQuantity()));
            } else {
                throw new BusinessException("无效的操作类型");
            }
            inventoryMapper.updateById(inventory);
        }

        // 创建库存操作记录
        InventoryRecord record = new InventoryRecord();
        record.setMaterialId(dto.getMaterialId());
        record.setUserId(userId);
        record.setType(dto.getType());
        record.setQuantity(dto.getQuantity());
        record.setReason(dto.getReason());
        inventoryRecordMapper.insert(record);
    }

    @Override
    public List<Inventory> getWarnings() {
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        // 使用 apply 拼接 SQL：quantity < warning_threshold
        wrapper.apply("quantity < warning_threshold");
        List<Inventory> warnings = inventoryMapper.selectList(wrapper);
        fillInventoryDisplayFields(warnings);
        return warnings;
    }

    @Override
    public PageResult<InventoryRecord> listRecords(Integer page, Integer size, Long materialId, Integer type) {
        Page<InventoryRecord> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<InventoryRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(materialId != null, InventoryRecord::getMaterialId, materialId);
        wrapper.eq(type != null, InventoryRecord::getType, type);
        wrapper.orderByDesc(InventoryRecord::getCreateTime);
        Page<InventoryRecord> result = inventoryRecordMapper.selectPage(pageParam, wrapper);
        fillInventoryRecordDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    private void fillInventoryDisplayFields(List<Inventory> inventories) {
        if (inventories == null || inventories.isEmpty()) {
            return;
        }

        Map<Long, AgriculturalMaterial> materialMap = agriculturalMaterialMapper
                .selectBatchIds(extractIds(inventories.stream().map(Inventory::getMaterialId).toList()))
                .stream()
                .collect(Collectors.toMap(AgriculturalMaterial::getId, material -> material));

        inventories.forEach(inventory -> {
            AgriculturalMaterial material = materialMap.get(inventory.getMaterialId());
            if (material == null) {
                return;
            }
            inventory.setMaterialName(material.getName());
            inventory.setMaterialType(getMaterialTypeName(material.getType()));
            inventory.setUnit(material.getUnit());
        });
    }

    private void fillInventoryRecordDisplayFields(List<InventoryRecord> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        Map<Long, String> materialNameMap = agriculturalMaterialMapper
                .selectBatchIds(extractIds(records.stream().map(InventoryRecord::getMaterialId).toList()))
                .stream()
                .collect(Collectors.toMap(AgriculturalMaterial::getId, AgriculturalMaterial::getName));
        Map<Long, String> operatorNameMap = userMapper.selectBatchIds(extractIds(records.stream().map(InventoryRecord::getUserId).toList()))
                .stream()
                .collect(Collectors.toMap(User::getId, user -> user.getRealName() != null ? user.getRealName() : user.getUsername()));

        records.forEach(record -> {
            record.setMaterialName(materialNameMap.get(record.getMaterialId()));
            record.setOperatorName(operatorNameMap.get(record.getUserId()));
            record.setRemark(record.getReason());
        });
    }

    private String getMaterialTypeName(Integer type) {
        if (type == null) {
            return null;
        }
        return switch (type) {
            case 1 -> "种子";
            case 2 -> "化肥";
            case 3 -> "农药";
            case 4 -> "工具";
            default -> "其他";
        };
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
