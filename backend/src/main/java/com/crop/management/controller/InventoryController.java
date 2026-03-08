package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.dto.InventoryOperationDTO;
import com.crop.management.entity.Inventory;
import com.crop.management.entity.InventoryRecord;
import com.crop.management.security.LoginUser;
import com.crop.management.service.InventoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    /**
     * 获取当前登录用户
     */
    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 分页查询库存列表
     */
    @GetMapping
    public Result<PageResult<Inventory>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long materialId) {
        return Result.success(inventoryService.list(page, size, materialId));
    }

    /**
     * 获取库存预警信息
     */
    @GetMapping("/warnings")
    public Result<List<Inventory>> getWarnings() {
        return Result.success(inventoryService.getWarnings());
    }

    /**
     * 库存出入库操作
     */
    @PostMapping("/operate")
    public Result<Void> operate(@Valid @RequestBody InventoryOperationDTO operationDTO) {
        LoginUser loginUser = getCurrentUser();
        inventoryService.operate(operationDTO, loginUser.getUserId());
        return Result.success();
    }

    /**
     * 分页查询库存操作记录
     */
    @GetMapping("/records")
    public Result<PageResult<InventoryRecord>> listRecords(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long materialId,
            @RequestParam(required = false) Integer type) {
        return Result.success(inventoryService.listRecords(page, size, materialId, type));
    }
}
