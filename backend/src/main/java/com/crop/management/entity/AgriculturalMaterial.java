package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("agricultural_material")
public class AgriculturalMaterial {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Integer type;       // 1-种子, 2-化肥, 3-农药, 4-工具, 5-其他
    private String unit;
    private String specification;
    private String manufacturer;
    private BigDecimal price;
    private String description;
    private String image;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
