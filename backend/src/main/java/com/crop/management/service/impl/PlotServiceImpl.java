package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.Plot;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.PlotMapper;
import com.crop.management.service.PlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlotServiceImpl implements PlotService {

    private final PlotMapper plotMapper;

    @Override
    public PageResult<Plot> list(Integer page, Integer size, String keyword, Long userId) {
        Page<Plot> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Plot> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(keyword), Plot::getName, keyword);
        wrapper.eq(userId != null, Plot::getUserId, userId);
        wrapper.orderByDesc(Plot::getCreateTime);
        Page<Plot> result = plotMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public Plot getById(Long id) {
        Plot plot = plotMapper.selectById(id);
        if (plot == null) {
            throw new BusinessException("地块不存在");
        }
        return plot;
    }

    @Override
    public void create(Plot plot) {
        plotMapper.insert(plot);
    }

    @Override
    public void update(Long id, Plot plot) {
        Plot existing = plotMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("地块不存在");
        }
        plot.setId(id);
        plotMapper.updateById(plot);
    }

    @Override
    public void delete(Long id) {
        Plot plot = plotMapper.selectById(id);
        if (plot == null) {
            throw new BusinessException("地块不存在");
        }
        plotMapper.deleteById(id);
    }

    @Override
    public List<Plot> listByUserId(Long userId) {
        LambdaQueryWrapper<Plot> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Plot::getUserId, userId);
        wrapper.orderByDesc(Plot::getCreateTime);
        return plotMapper.selectList(wrapper);
    }
}
