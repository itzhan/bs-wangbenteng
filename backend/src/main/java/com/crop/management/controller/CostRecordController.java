package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.CostRecord;
import com.crop.management.service.CostRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/costs")
@RequiredArgsConstructor
public class CostRecordController {

    private final CostRecordService costRecordService;

    /**
     * 分页查询成本记录
     */
    @GetMapping
    public Result<PageResult<CostRecord>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long planId,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Integer type,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(costRecordService.list(page, size, planId, userId, type, startDate, endDate));
    }

    /**
     * 根据ID查询成本记录
     */
    @GetMapping("/{id}")
    public Result<CostRecord> getById(@PathVariable Long id) {
        return Result.success(costRecordService.getById(id));
    }

    /**
     * 新增成本记录
     */
    @PostMapping
    public Result<Void> create(@RequestBody CostRecord costRecord) {
        costRecordService.create(costRecord);
        return Result.success();
    }

    /**
     * 修改成本记录
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody CostRecord costRecord) {
        costRecordService.update(id, costRecord);
        return Result.success();
    }

    /**
     * 删除成本记录
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        costRecordService.delete(id);
        return Result.success();
    }
}
