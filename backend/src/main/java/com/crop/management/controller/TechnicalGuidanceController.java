package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.TechnicalGuidance;
import com.crop.management.service.TechnicalGuidanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/guidance")
@RequiredArgsConstructor
public class TechnicalGuidanceController {

    private final TechnicalGuidanceService technicalGuidanceService;

    /**
     * 分页查询技术指导列表
     */
    @GetMapping
    public Result<PageResult<TechnicalGuidance>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long cropId,
            @RequestParam(required = false) String keyword) {
        return Result.success(technicalGuidanceService.list(page, size, cropId, keyword));
    }

    /**
     * 根据ID查询技术指导
     */
    @GetMapping("/{id}")
    public Result<TechnicalGuidance> getById(@PathVariable Long id) {
        return Result.success(technicalGuidanceService.getById(id));
    }

    /**
     * 新增技术指导
     */
    @PostMapping
    public Result<Void> create(@RequestBody TechnicalGuidance guidance) {
        technicalGuidanceService.create(guidance);
        return Result.success();
    }

    /**
     * 修改技术指导
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody TechnicalGuidance guidance) {
        technicalGuidanceService.update(id, guidance);
        return Result.success();
    }

    /**
     * 删除技术指导
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        technicalGuidanceService.delete(id);
        return Result.success();
    }
}
