package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.AgriculturalMaterial;
import com.crop.management.service.MaterialService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/materials")
@RequiredArgsConstructor
public class MaterialController {

    private final MaterialService materialService;

    /**
     * 分页查询农资列表
     */
    @GetMapping
    public Result<PageResult<AgriculturalMaterial>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer type) {
        return Result.success(materialService.list(page, size, keyword, type));
    }

    /**
     * 根据ID查询农资
     */
    @GetMapping("/{id}")
    public Result<AgriculturalMaterial> getById(@PathVariable Long id) {
        return Result.success(materialService.getById(id));
    }

    /**
     * 新增农资
     */
    @PostMapping
    public Result<Void> create(@RequestBody AgriculturalMaterial material) {
        materialService.create(material);
        return Result.success();
    }

    /**
     * 修改农资
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody AgriculturalMaterial material) {
        materialService.update(id, material);
        return Result.success();
    }

    /**
     * 删除农资
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        materialService.delete(id);
        return Result.success();
    }
}
