package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("cost_record")
public class CostRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long planId;
    private Long userId;
    private Integer type;       // 1-种子, 2-化肥, 3-农药, 4-人工, 5-设备, 6-其他
    private BigDecimal amount;
    private String description;
    private LocalDate costDate;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    @TableField(exist = false)
    private String planName;
    @TableField(exist = false)
    private String costType;
    @TableField(exist = false)
    private String remark;
}
