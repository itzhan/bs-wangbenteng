package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.CostRecord;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.CostRecordMapper;
import com.crop.management.service.CostRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class CostRecordServiceImpl implements CostRecordService {

    private final CostRecordMapper costRecordMapper;

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
}
