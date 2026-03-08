package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.dto.PlanReviewDTO;
import com.crop.management.entity.PlantingPlan;

import java.util.List;

public interface PlantingPlanService {

    PageResult<PlantingPlan> list(Integer page, Integer size, Long userId, Long cropId, Integer status);

    PlantingPlan getById(Long id);

    void create(PlantingPlan plan);

    void update(Long id, PlantingPlan plan);

    void delete(Long id);

    void review(Long id, PlanReviewDTO dto, Long reviewerId);

    void startPlan(Long id);

    void completePlan(Long id);

    List<PlantingPlan> listByUserId(Long userId);
}
