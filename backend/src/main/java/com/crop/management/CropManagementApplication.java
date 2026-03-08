package com.crop.management;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.crop.management.mapper")
public class CropManagementApplication {

    public static void main(String[] args) {
        SpringApplication.run(CropManagementApplication.class, args);
    }
}
