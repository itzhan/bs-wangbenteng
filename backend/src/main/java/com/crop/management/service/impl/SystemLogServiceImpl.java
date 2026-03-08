package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.SystemLog;
import com.crop.management.mapper.SystemLogMapper;
import com.crop.management.service.SystemLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class SystemLogServiceImpl implements SystemLogService {

    private final SystemLogMapper systemLogMapper;

    @Override
    public PageResult<SystemLog> list(Integer page, Integer size, String username, String module,
                                      String startDate, String endDate) {
        Page<SystemLog> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SystemLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(username), SystemLog::getUsername, username);
        wrapper.eq(StringUtils.hasText(module), SystemLog::getModule, module);
        if (StringUtils.hasText(startDate)) {
            wrapper.ge(SystemLog::getCreateTime,
                       LocalDateTime.parse(startDate + " 00:00:00", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        if (StringUtils.hasText(endDate)) {
            wrapper.le(SystemLog::getCreateTime,
                       LocalDateTime.parse(endDate + " 23:59:59", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        wrapper.orderByDesc(SystemLog::getCreateTime);
        Page<SystemLog> result = systemLogMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public void addLog(Long userId, String username, String module, String action,
                       String description, String ip) {
        SystemLog log = new SystemLog();
        log.setUserId(userId);
        log.setUsername(username);
        log.setModule(module);
        log.setAction(action);
        log.setDescription(description);
        log.setIp(ip);
        systemLogMapper.insert(log);
    }
}
