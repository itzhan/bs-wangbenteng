package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.Crop;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.CropMapper;
import com.crop.management.service.CropService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class CropServiceImpl implements CropService {

    private final CropMapper cropMapper;

    @Override
    public PageResult<Crop> list(Integer page, Integer size, String name, String variety) {
        Page<Crop> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Crop> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(name), Crop::getName, name);
        wrapper.like(StringUtils.hasText(variety), Crop::getVariety, variety);
        wrapper.orderByDesc(Crop::getCreateTime);
        Page<Crop> result = cropMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public Crop getById(Long id) {
        Crop crop = cropMapper.selectById(id);
        if (crop == null) {
            throw new BusinessException("农作物不存在");
        }
        return crop;
    }

    @Override
    public void create(Crop crop) {
        cropMapper.insert(crop);
    }

    @Override
    public void update(Long id, Crop crop) {
        Crop existing = cropMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("农作物不存在");
        }
        crop.setId(id);
        cropMapper.updateById(crop);
    }

    @Override
    public void delete(Long id) {
        Crop crop = cropMapper.selectById(id);
        if (crop == null) {
            throw new BusinessException("农作物不存在");
        }
        cropMapper.deleteById(id);
    }
}
