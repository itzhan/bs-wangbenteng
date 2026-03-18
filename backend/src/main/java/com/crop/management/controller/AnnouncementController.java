package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.entity.Announcement;
import com.crop.management.security.LoginUser;
import com.crop.management.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 分页查询公告列表
     */
    @GetMapping
    public Result<PageResult<Announcement>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status) {
        return Result.success(announcementService.list(page, size, keyword, status));
    }

    /**
     * 根据ID查询公告
     */
    @GetMapping("/{id}")
    public Result<Announcement> getById(@PathVariable Long id) {
        return Result.success(announcementService.getById(id));
    }

    /**
     * 新增公告
     */
    @PostMapping
    public Result<Void> create(@RequestBody Announcement announcement) {
        announcement.setPublisherId(getCurrentUser().getUserId());
        announcementService.create(announcement);
        return Result.success();
    }

    /**
     * 修改公告
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody Announcement announcement) {
        announcementService.update(id, announcement);
        return Result.success();
    }

    /**
     * 删除公告
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        announcementService.delete(id);
        return Result.success();
    }

    /**
     * 发布公告
     */
    @PutMapping("/{id}/publish")
    public Result<Void> publish(@PathVariable Long id) {
        announcementService.publish(id);
        return Result.success();
    }

    /**
     * 查询已发布公告列表
     */
    @GetMapping("/published")
    public Result<PageResult<Announcement>> listPublished(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(announcementService.listPublished(page, size));
    }
}
