package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.dto.PlanReviewDTO;
import com.crop.management.entity.PlantingPlan;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.PlantingPlanMapper;
import com.crop.management.service.PlantingPlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlantingPlanServiceImpl implements PlantingPlanService {

    private final PlantingPlanMapper plantingPlanMapper;

    @Override
    public PageResult<PlantingPlan> list(Integer page, Integer size, Long userId, Long cropId, Integer status) {
        Page<PlantingPlan> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PlantingPlan> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(userId != null, PlantingPlan::getUserId, userId);
        wrapper.eq(cropId != null, PlantingPlan::getCropId, cropId);
        wrapper.eq(status != null, PlantingPlan::getStatus, status);
        wrapper.orderByDesc(PlantingPlan::getCreateTime);
        Page<PlantingPlan> result = plantingPlanMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public PlantingPlan getById(Long id) {
        PlantingPlan plan = plantingPlanMapper.selectById(id);
        if (plan == null) {
            throw new BusinessException("种植计划不存在");
        }
        return plan;
    }

    @Override
    public void create(PlantingPlan plan) {
        plan.setStatus(0); // 待审核
        plantingPlanMapper.insert(plan);
    }

    @Override
    public void update(Long id, PlantingPlan plan) {
        PlantingPlan existing = plantingPlanMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("种植计划不存在");
        }
        if (existing.getStatus() != 0) {
            throw new BusinessException("只能修改待审核的计划");
        }
        plan.setId(id);
        plantingPlanMapper.updateById(plan);
    }

    @Override
    public void delete(Long id) {
        PlantingPlan plan = plantingPlanMapper.selectById(id);
        if (plan == null) {
            throw new BusinessException("种植计划不存在");
        }
        plantingPlanMapper.deleteById(id);
    }

    @Override
    public void review(Long id, PlanReviewDTO dto, Long reviewerId) {
        PlantingPlan plan = plantingPlanMapper.selectById(id);
        if (plan == null) {
            throw new BusinessException("种植计划不存在");
        }
        if (plan.getStatus() != 0) {
            throw new BusinessException("该计划不是待审核状态");
        }
        plan.setStatus(dto.getStatus()); // 1-通过, 2-拒绝
        plan.setReviewNote(dto.getReviewNote());
        plan.setReviewerId(reviewerId);
        plan.setReviewTime(LocalDateTime.now());
        plantingPlanMapper.updateById(plan);
    }

    @Override
    public void startPlan(Long id) {
        PlantingPlan plan = plantingPlanMapper.selectById(id);
        if (plan == null) {
            throw new BusinessException("种植计划不存在");
        }
        if (plan.getStatus() != 1) {
            throw new BusinessException("只有审核通过的计划才能开始执行");
        }
        plan.setStatus(3); // 进行中
        plan.setActualStartDate(LocalDate.now());
        plantingPlanMapper.updateById(plan);
    }

    @Override
    public void completePlan(Long id) {
        PlantingPlan plan = plantingPlanMapper.selectById(id);
        if (plan == null) {
            throw new BusinessException("种植计划不存在");
        }
        if (plan.getStatus() != 3) {
            throw new BusinessException("只有进行中的计划才能完成");
        }
        plan.setStatus(4); // 已完成
        plan.setActualEndDate(LocalDate.now());
        plantingPlanMapper.updateById(plan);
    }

    @Override
    public List<PlantingPlan> listByUserId(Long userId) {
        LambdaQueryWrapper<PlantingPlan> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlantingPlan::getUserId, userId);
        wrapper.orderByDesc(PlantingPlan::getCreateTime);
        return plantingPlanMapper.selectList(wrapper);
    }
}
