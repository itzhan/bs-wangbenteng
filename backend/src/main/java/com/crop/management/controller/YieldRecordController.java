package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.YieldRecord;
import com.crop.management.service.YieldRecordService;
import com.crop.management.security.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/yields")
@RequiredArgsConstructor
public class YieldRecordController {

    private final YieldRecordService yieldRecordService;

    /**
     * 分页查询产量记录
     */
    @GetMapping
    public Result<PageResult<YieldRecord>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long planId,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(yieldRecordService.list(page, size, planId, userId, startDate, endDate));
    }

    /**
     * 根据ID查询产量记录
     */
    @GetMapping("/{id}")
    public Result<YieldRecord> getById(@PathVariable Long id) {
        return Result.success(yieldRecordService.getById(id));
    }

    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 新增产量记录
     */
    @PostMapping
    public Result<Void> create(@RequestBody YieldRecord yieldRecord) {
        yieldRecord.setUserId(getCurrentUser().getUserId());
        yieldRecordService.create(yieldRecord);
        return Result.success();
    }

    /**
     * 修改产量记录
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody YieldRecord yieldRecord) {
        yieldRecordService.update(id, yieldRecord);
        return Result.success();
    }

    /**
     * 删除产量记录
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        yieldRecordService.delete(id);
        return Result.success();
    }
}
