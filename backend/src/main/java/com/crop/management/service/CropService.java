package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.Crop;

public interface CropService {

    PageResult<Crop> list(Integer page, Integer size, String name, String variety);

    Crop getById(Long id);

    void create(Crop crop);

    void update(Long id, Crop crop);

    void delete(Long id);
}
