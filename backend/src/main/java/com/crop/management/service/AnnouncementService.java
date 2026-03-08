package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.Announcement;

public interface AnnouncementService {

    PageResult<Announcement> list(Integer page, Integer size, String keyword, Integer status);

    Announcement getById(Long id);

    void create(Announcement announcement);

    void update(Long id, Announcement announcement);

    void delete(Long id);

    void publish(Long id);

    void unpublish(Long id);

    PageResult<Announcement> listPublished(Integer page, Integer size);
}
