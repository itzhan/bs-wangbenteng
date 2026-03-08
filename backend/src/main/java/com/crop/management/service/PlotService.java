package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.Plot;

import java.util.List;

public interface PlotService {

    PageResult<Plot> list(Integer page, Integer size, String keyword, Long userId);

    Plot getById(Long id);

    void create(Plot plot);

    void update(Long id, Plot plot);

    void delete(Long id);

    List<Plot> listByUserId(Long userId);
}
