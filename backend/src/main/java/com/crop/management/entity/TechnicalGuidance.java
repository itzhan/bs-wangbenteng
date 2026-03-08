package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("technical_guidance")
public class TechnicalGuidance {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String content;
    private Long cropId;
    private Long authorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
