package com.crop.management.controller;

import com.crop.management.common.Result;
import com.crop.management.service.DashboardService;
import com.crop.management.vo.DashboardVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    /**
     * 获取仪表盘统计数据
     */
    @GetMapping
    public Result<DashboardVO> getDashboardData() {
        return Result.success(dashboardService.getDashboardData());
    }
}
