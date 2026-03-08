package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("crop")
public class Crop {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String variety;
    private Integer growthCycle;
    private String plantingSeason;
    private String suitableRegion;
    private String description;
    private String image;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
