package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.SystemConfig;

public interface SystemConfigService {

    PageResult<SystemConfig> list(Integer page, Integer size, String keyword);

    SystemConfig getById(Long id);

    SystemConfig getByKey(String key);

    void create(SystemConfig config);

    void update(Long id, SystemConfig config);

    void delete(Long id);
}
