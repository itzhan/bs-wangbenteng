package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.AgriculturalMaterial;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.AgriculturalMaterialMapper;
import com.crop.management.service.MaterialService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class MaterialServiceImpl implements MaterialService {

    private final AgriculturalMaterialMapper materialMapper;

    @Override
    public PageResult<AgriculturalMaterial> list(Integer page, Integer size, String name, Integer type) {
        Page<AgriculturalMaterial> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<AgriculturalMaterial> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(name), AgriculturalMaterial::getName, name);
        wrapper.eq(type != null, AgriculturalMaterial::getType, type);
        wrapper.orderByDesc(AgriculturalMaterial::getCreateTime);
        Page<AgriculturalMaterial> result = materialMapper.selectPage(pageParam, wrapper);
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public AgriculturalMaterial getById(Long id) {
        AgriculturalMaterial material = materialMapper.selectById(id);
        if (material == null) {
            throw new BusinessException("农资不存在");
        }
        return material;
    }

    @Override
    public void create(AgriculturalMaterial material) {
        materialMapper.insert(material);
    }

    @Override
    public void update(Long id, AgriculturalMaterial material) {
        AgriculturalMaterial existing = materialMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("农资不存在");
        }
        material.setId(id);
        materialMapper.updateById(material);
    }

    @Override
    public void delete(Long id) {
        AgriculturalMaterial material = materialMapper.selectById(id);
        if (material == null) {
            throw new BusinessException("农资不存在");
        }
        materialMapper.deleteById(id);
    }
}
