package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.Plot;
import com.crop.management.security.LoginUser;
import com.crop.management.service.PlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/plots")
@RequiredArgsConstructor
public class PlotController {

    private final PlotService plotService;

    /**
     * 获取当前登录用户
     */
    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 分页查询地块列表
     */
    @GetMapping
    public Result<PageResult<Plot>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        return Result.success(plotService.list(page, size, keyword, null));
    }

    /**
     * 根据ID查询地块
     */
    @GetMapping("/{id}")
    public Result<Plot> getById(@PathVariable Long id) {
        return Result.success(plotService.getById(id));
    }

    /**
     * 新增地块
     */
    @PostMapping
    public Result<Void> create(@RequestBody Plot plot) {
        plotService.create(plot);
        return Result.success();
    }

    /**
     * 修改地块
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody Plot plot) {
        plotService.update(id, plot);
        return Result.success();
    }

    /**
     * 删除地块
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        plotService.delete(id);
        return Result.success();
    }

    /**
     * 查询当前用户的地块
     */
    @GetMapping("/my")
    public Result<java.util.List<Plot>> myPlots() {
        LoginUser loginUser = getCurrentUser();
        return Result.success(plotService.listByUserId(loginUser.getUserId()));
    }
}
