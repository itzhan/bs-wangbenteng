package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.dto.PlanReviewDTO;
import com.crop.management.entity.PlantingPlan;
import com.crop.management.security.LoginUser;
import com.crop.management.service.PlantingPlanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/plans")
@RequiredArgsConstructor
public class PlantingPlanController {

    private final PlantingPlanService plantingPlanService;

    /**
     * 获取当前登录用户
     */
    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 分页查询种植计划列表
     */
    @GetMapping
    public Result<PageResult<PlantingPlan>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long cropId,
            @RequestParam(required = false) Integer status) {
        return Result.success(plantingPlanService.list(page, size, userId, cropId, status));
    }

    /**
     * 根据ID查询种植计划
     */
    @GetMapping("/{id}")
    public Result<PlantingPlan> getById(@PathVariable Long id) {
        return Result.success(plantingPlanService.getById(id));
    }

    /**
     * 新增种植计划
     */
    @PostMapping
    public Result<Void> create(@RequestBody PlantingPlan plantingPlan) {
        plantingPlanService.create(plantingPlan);
        return Result.success();
    }

    /**
     * 修改种植计划
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody PlantingPlan plantingPlan) {
        plantingPlanService.update(id, plantingPlan);
        return Result.success();
    }

    /**
     * 删除种植计划
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        plantingPlanService.delete(id);
        return Result.success();
    }

    /**
     * 审核种植计划
     */
    @PutMapping("/{id}/review")
    public Result<Void> review(@PathVariable Long id, @Valid @RequestBody PlanReviewDTO reviewDTO) {
        LoginUser loginUser = getCurrentUser();
        plantingPlanService.review(id, reviewDTO, loginUser.getUserId());
        return Result.success();
    }

    /**
     * 开始执行种植计划
     */
    @PutMapping("/{id}/start")
    public Result<Void> start(@PathVariable Long id) {
        plantingPlanService.startPlan(id);
        return Result.success();
    }

    /**
     * 完成种植计划
     */
    @PutMapping("/{id}/complete")
    public Result<Void> complete(@PathVariable Long id) {
        plantingPlanService.completePlan(id);
        return Result.success();
    }

    /**
     * 查询当前用户的种植计划
     */
    @GetMapping("/my")
    public Result<java.util.List<PlantingPlan>> myPlans() {
        LoginUser loginUser = getCurrentUser();
        return Result.success(plantingPlanService.listByUserId(loginUser.getUserId()));
    }
}
