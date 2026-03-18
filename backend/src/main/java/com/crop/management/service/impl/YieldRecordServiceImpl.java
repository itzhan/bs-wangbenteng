package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.Crop;
import com.crop.management.entity.PlantingPlan;
import com.crop.management.entity.YieldRecord;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.CropMapper;
import com.crop.management.mapper.PlantingPlanMapper;
import com.crop.management.mapper.YieldRecordMapper;
import com.crop.management.service.YieldRecordService;
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
public class YieldRecordServiceImpl implements YieldRecordService {

    private final YieldRecordMapper yieldRecordMapper;
    private final PlantingPlanMapper plantingPlanMapper;
    private final CropMapper cropMapper;

    @Override
    public PageResult<YieldRecord> list(Integer page, Integer size, Long planId, Long userId,
                                        String startDate, String endDate) {
        Page<YieldRecord> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<YieldRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(planId != null, YieldRecord::getPlanId, planId);
        wrapper.eq(userId != null, YieldRecord::getUserId, userId);
        wrapper.ge(StringUtils.hasText(startDate), YieldRecord::getHarvestDate, 
                   StringUtils.hasText(startDate) ? LocalDate.parse(startDate) : null);
        wrapper.le(StringUtils.hasText(endDate), YieldRecord::getHarvestDate, 
                   StringUtils.hasText(endDate) ? LocalDate.parse(endDate) : null);
        wrapper.orderByDesc(YieldRecord::getHarvestDate);
        Page<YieldRecord> result = yieldRecordMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public YieldRecord getById(Long id) {
        YieldRecord record = yieldRecordMapper.selectById(id);
        if (record == null) {
            throw new BusinessException("产量记录不存在");
        }
        return record;
    }

    @Override
    public void create(YieldRecord record) {
        yieldRecordMapper.insert(record);
    }

    @Override
    public void update(Long id, YieldRecord record) {
        YieldRecord existing = yieldRecordMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("产量记录不存在");
        }
        record.setId(id);
        yieldRecordMapper.updateById(record);
    }

    @Override
    public void delete(Long id) {
        YieldRecord record = yieldRecordMapper.selectById(id);
        if (record == null) {
            throw new BusinessException("产量记录不存在");
        }
        yieldRecordMapper.deleteById(id);
    }

    private void fillDisplayFields(List<YieldRecord> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        Map<Long, PlantingPlan> planMap = plantingPlanMapper.selectBatchIds(extractIds(records.stream().map(YieldRecord::getPlanId).toList()))
                .stream()
                .collect(Collectors.toMap(PlantingPlan::getId, plan -> plan));
        Map<Long, String> cropNameMap = cropMapper.selectBatchIds(extractIds(planMap.values().stream().map(PlantingPlan::getCropId).toList()))
                .stream()
                .collect(Collectors.toMap(Crop::getId, Crop::getName));

        records.forEach(record -> {
            PlantingPlan plan = planMap.get(record.getPlanId());
            if (plan == null) {
                return;
            }
            record.setPlanName(plan.getPlanName());
            record.setCropName(cropNameMap.get(plan.getCropId()));
        });
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
