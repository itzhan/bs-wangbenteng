package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.SystemLog;

public interface SystemLogService {

    PageResult<SystemLog> list(Integer page, Integer size, String username, String module,
                               String startDate, String endDate);

    void addLog(Long userId, String username, String module, String action,
                String description, String ip);
}
