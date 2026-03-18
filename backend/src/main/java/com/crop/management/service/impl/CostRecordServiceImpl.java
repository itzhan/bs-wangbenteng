package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.CostRecord;
import com.crop.management.entity.PlantingPlan;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.CostRecordMapper;
import com.crop.management.mapper.PlantingPlanMapper;
import com.crop.management.service.CostRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CostRecordServiceImpl implements CostRecordService {

    private final CostRecordMapper costRecordMapper;
    private final PlantingPlanMapper plantingPlanMapper;

    @Override
    public PageResult<CostRecord> list(Integer page, Integer size, Long planId, Long userId,
                                       Integer type, String startDate, String endDate) {
        Page<CostRecord> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<CostRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(planId != null, CostRecord::getPlanId, planId);
        wrapper.eq(userId != null, CostRecord::getUserId, userId);
        wrapper.eq(type != null, CostRecord::getType, type);
        wrapper.ge(StringUtils.hasText(startDate), CostRecord::getCostDate, 
                   StringUtils.hasText(startDate) ? LocalDate.parse(startDate) : null);
        wrapper.le(StringUtils.hasText(endDate), CostRecord::getCostDate, 
                   StringUtils.hasText(endDate) ? LocalDate.parse(endDate) : null);
        wrapper.orderByDesc(CostRecord::getCostDate);
        Page<CostRecord> result = costRecordMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public CostRecord getById(Long id) {
        CostRecord record = costRecordMapper.selectById(id);
        if (record == null) {
            throw new BusinessException("成本记录不存在");
        }
        return record;
    }

    @Override
    public void create(CostRecord record) {
        costRecordMapper.insert(record);
    }

    @Override
    public void update(Long id, CostRecord record) {
        CostRecord existing = costRecordMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("成本记录不存在");
        }
        record.setId(id);
        costRecordMapper.updateById(record);
    }

    @Override
    public void delete(Long id) {
        CostRecord record = costRecordMapper.selectById(id);
        if (record == null) {
            throw new BusinessException("成本记录不存在");
        }
        costRecordMapper.deleteById(id);
    }

    private void fillDisplayFields(List<CostRecord> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        Map<Long, String> planNameMap = plantingPlanMapper.selectBatchIds(extractIds(records.stream().map(CostRecord::getPlanId).toList()))
                .stream()
                .collect(Collectors.toMap(PlantingPlan::getId, PlantingPlan::getPlanName));

        records.forEach(record -> {
            record.setPlanName(planNameMap.get(record.getPlanId()));
            record.setCostType(getCostTypeName(record.getType()));
            record.setRemark(record.getDescription());
        });
    }

    private String getCostTypeName(Integer type) {
        if (type == null) {
            return null;
        }
        return switch (type) {
            case 1 -> "种子";
            case 2 -> "化肥";
            case 3 -> "农药";
            case 4 -> "人工";
            case 5 -> "设备";
            default -> "其他";
        };
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
