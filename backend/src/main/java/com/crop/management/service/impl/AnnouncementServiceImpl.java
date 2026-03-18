package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.Announcement;
import com.crop.management.entity.User;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.AnnouncementMapper;
import com.crop.management.mapper.UserMapper;
import com.crop.management.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnnouncementServiceImpl implements AnnouncementService {

    private final AnnouncementMapper announcementMapper;
    private final UserMapper userMapper;

    @Override
    public PageResult<Announcement> list(Integer page, Integer size, String keyword, Integer status) {
        Page<Announcement> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Announcement> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(keyword), Announcement::getTitle, keyword);
        wrapper.eq(status != null, Announcement::getStatus, status);
        wrapper.orderByDesc(Announcement::getCreateTime);
        Page<Announcement> result = announcementMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public Announcement getById(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new BusinessException("公告不存在");
        }
        return announcement;
    }

    @Override
    public void create(Announcement announcement) {
        announcement.setStatus(0); // 默认草稿
        announcementMapper.insert(announcement);
    }

    @Override
    public void update(Long id, Announcement announcement) {
        Announcement existing = announcementMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("公告不存在");
        }
        if (announcement.getPublisherId() == null) {
            announcement.setPublisherId(existing.getPublisherId());
        }
        if (announcement.getStatus() == null) {
            announcement.setStatus(existing.getStatus());
        }
        announcement.setId(id);
        announcementMapper.updateById(announcement);
    }

    @Override
    public void delete(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new BusinessException("公告不存在");
        }
        announcementMapper.deleteById(id);
    }

    @Override
    public void publish(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new BusinessException("公告不存在");
        }
        announcement.setStatus(1); // 已发布
        announcementMapper.updateById(announcement);
    }

    @Override
    public void unpublish(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new BusinessException("公告不存在");
        }
        announcement.setStatus(0); // 草稿
        announcementMapper.updateById(announcement);
    }

    @Override
    public PageResult<Announcement> listPublished(Integer page, Integer size) {
        Page<Announcement> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Announcement> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Announcement::getStatus, 1);
        wrapper.orderByDesc(Announcement::getCreateTime);
        Page<Announcement> result = announcementMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    private void fillDisplayFields(List<Announcement> announcements) {
        if (announcements == null || announcements.isEmpty()) {
            return;
        }

        Map<Long, String> userNameMap = userMapper.selectBatchIds(extractIds(announcements.stream().map(Announcement::getPublisherId).toList()))
                .stream()
                .collect(Collectors.toMap(User::getId, user -> user.getRealName() != null ? user.getRealName() : user.getUsername()));
        announcements.forEach(announcement -> announcement.setAuthorName(userNameMap.get(announcement.getPublisherId())));
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
