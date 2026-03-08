package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.Crop;
import com.crop.management.service.CropService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/crops")
@RequiredArgsConstructor
public class CropController {

    private final CropService cropService;

    /**
     * 分页查询农作物列表
     */
    @GetMapping
    public Result<PageResult<Crop>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        return Result.success(cropService.list(page, size, keyword, null));
    }

    /**
     * 根据ID查询农作物
     */
    @GetMapping("/{id}")
    public Result<Crop> getById(@PathVariable Long id) {
        return Result.success(cropService.getById(id));
    }

    /**
     * 新增农作物
     */
    @PostMapping
    public Result<Void> create(@RequestBody Crop crop) {
        cropService.create(crop);
        return Result.success();
    }

    /**
     * 修改农作物
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody Crop crop) {
        cropService.update(id, crop);
        return Result.success();
    }

    /**
     * 删除农作物
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cropService.delete(id);
        return Result.success();
    }
}
