package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.dto.InventoryOperationDTO;
import com.crop.management.entity.Inventory;
import com.crop.management.entity.InventoryRecord;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.InventoryMapper;
import com.crop.management.mapper.InventoryRecordMapper;
import com.crop.management.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final InventoryMapper inventoryMapper;
    private final InventoryRecordMapper inventoryRecordMapper;

    @Override
    public PageResult<Inventory> list(Integer page, Integer size, Long materialId) {
        Page<Inventory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(materialId != null, Inventory::getMaterialId, materialId);
        wrapper.orderByDesc(Inventory::getUpdateTime);
        Page<Inventory> result = inventoryMapper.selectPage(pageParam, wrapper);
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
        return inventoryMapper.selectList(wrapper);
    }

    @Override
    public PageResult<InventoryRecord> listRecords(Integer page, Integer size, Long materialId, Integer type) {
        Page<InventoryRecord> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<InventoryRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(materialId != null, InventoryRecord::getMaterialId, materialId);
        wrapper.eq(type != null, InventoryRecord::getType, type);
        wrapper.orderByDesc(InventoryRecord::getCreateTime);
        Page<InventoryRecord> result = inventoryRecordMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }
}
