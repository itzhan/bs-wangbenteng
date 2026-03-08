package com.crop.management.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.crop.management.entity.Crop;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CropMapper extends BaseMapper<Crop> {
}
