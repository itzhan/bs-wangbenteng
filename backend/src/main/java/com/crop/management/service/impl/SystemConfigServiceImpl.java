package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.SystemConfig;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.SystemConfigMapper;
import com.crop.management.service.SystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class SystemConfigServiceImpl implements SystemConfigService {

    private final SystemConfigMapper systemConfigMapper;

    @Override
    public PageResult<SystemConfig> list(Integer page, Integer size, String keyword) {
        Page<SystemConfig> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SystemConfig> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.like(SystemConfig::getConfigKey, keyword)
                   .or()
                   .like(SystemConfig::getDescription, keyword);
        }
        wrapper.orderByDesc(SystemConfig::getCreateTime);
        Page<SystemConfig> result = systemConfigMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public SystemConfig getById(Long id) {
        SystemConfig config = systemConfigMapper.selectById(id);
        if (config == null) {
            throw new BusinessException("配置项不存在");
        }
        return config;
    }

    @Override
    public SystemConfig getByKey(String key) {
        LambdaQueryWrapper<SystemConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SystemConfig::getConfigKey, key);
        return systemConfigMapper.selectOne(wrapper);
    }

    @Override
    public void create(SystemConfig config) {
        // 检查 key 是否重复
        LambdaQueryWrapper<SystemConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SystemConfig::getConfigKey, config.getConfigKey());
        if (systemConfigMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("配置项 Key 已存在");
        }
        systemConfigMapper.insert(config);
    }

    @Override
    public void update(Long id, SystemConfig config) {
        SystemConfig existing = systemConfigMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("配置项不存在");
        }
        // 如果修改了 key，检查是否冲突
        if (StringUtils.hasText(config.getConfigKey()) && !config.getConfigKey().equals(existing.getConfigKey())) {
            LambdaQueryWrapper<SystemConfig> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(SystemConfig::getConfigKey, config.getConfigKey());
            if (systemConfigMapper.selectCount(wrapper) > 0) {
                throw new BusinessException("配置项 Key 已存在");
            }
        }
        config.setId(id);
        systemConfigMapper.updateById(config);
    }

    @Override
    public void delete(Long id) {
        SystemConfig config = systemConfigMapper.selectById(id);
        if (config == null) {
            throw new BusinessException("配置项不存在");
        }
        systemConfigMapper.deleteById(id);
    }
}
