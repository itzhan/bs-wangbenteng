package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.AgriculturalMaterial;

public interface MaterialService {

    PageResult<AgriculturalMaterial> list(Integer page, Integer size, String name, Integer type);

    AgriculturalMaterial getById(Long id);

    void create(AgriculturalMaterial material);

    void update(Long id, AgriculturalMaterial material);

    void delete(Long id);
}
