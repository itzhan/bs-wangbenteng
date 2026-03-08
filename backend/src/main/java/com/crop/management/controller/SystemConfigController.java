package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.SystemConfig;
import com.crop.management.service.SystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/config")
@RequiredArgsConstructor
public class SystemConfigController {

    private final SystemConfigService systemConfigService;

    /**
     * 分页查询系统配置列表
     */
    @GetMapping
    public Result<PageResult<SystemConfig>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        return Result.success(systemConfigService.list(page, size, keyword));
    }

    /**
     * 根据ID查询系统配置
     */
    @GetMapping("/{id}")
    public Result<SystemConfig> getById(@PathVariable Long id) {
        return Result.success(systemConfigService.getById(id));
    }

    /**
     * 根据key查询系统配置
     */
    @GetMapping("/key/{key}")
    public Result<SystemConfig> getByKey(@PathVariable String key) {
        return Result.success(systemConfigService.getByKey(key));
    }

    /**
     * 新增系统配置
     */
    @PostMapping
    public Result<Void> create(@RequestBody SystemConfig config) {
        systemConfigService.create(config);
        return Result.success();
    }

    /**
     * 修改系统配置
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody SystemConfig config) {
        systemConfigService.update(id, config);
        return Result.success();
    }

    /**
     * 删除系统配置
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        systemConfigService.delete(id);
        return Result.success();
    }
}
