package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.FieldOperation;
import com.crop.management.service.FieldOperationService;
import com.crop.management.security.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/operations")
@RequiredArgsConstructor
public class FieldOperationController {

    private final FieldOperationService fieldOperationService;

    /**
     * 分页查询田间操作记录
     */
    @GetMapping
    public Result<PageResult<FieldOperation>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long planId,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Integer operationType,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(fieldOperationService.list(page, size, planId, userId, operationType, startDate, endDate));
    }

    /**
     * 根据ID查询田间操作
     */
    @GetMapping("/{id}")
    public Result<FieldOperation> getById(@PathVariable Long id) {
        return Result.success(fieldOperationService.getById(id));
    }

    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 新增田间操作
     */
    @PostMapping
    public Result<Void> create(@RequestBody FieldOperation fieldOperation) {
        fieldOperation.setUserId(getCurrentUser().getUserId());
        fieldOperationService.create(fieldOperation);
        return Result.success();
    }

    /**
     * 修改田间操作
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody FieldOperation fieldOperation) {
        fieldOperationService.update(id, fieldOperation);
        return Result.success();
    }

    /**
     * 删除田间操作
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        fieldOperationService.delete(id);
        return Result.success();
    }
}
