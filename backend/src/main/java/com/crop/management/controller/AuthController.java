package com.crop.management.controller;

import com.crop.management.common.Result;
import com.crop.management.dto.LoginDTO;
import com.crop.management.dto.RegisterDTO;
import com.crop.management.security.JwtUtil;
import com.crop.management.security.LoginUser;
import com.crop.management.service.UserService;
import com.crop.management.vo.LoginVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO loginDTO) {
        // 认证
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginDTO.getUsername(), loginDTO.getPassword())
        );
        // 获取登录用户信息
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        // 生成JWT令牌
        String token = jwtUtil.generateToken(loginUser.getUserId(), loginUser.getUsername(), loginUser.getRole());
        // 查询完整用户信息
        var user = userService.getById(loginUser.getUserId());
        // 构建返回对象
        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setUserId(loginUser.getUserId());
        loginVO.setUsername(loginUser.getUsername());
        loginVO.setRealName(user.getRealName());
        loginVO.setRole(loginUser.getRole());
        loginVO.setAvatar(user.getAvatar());
        return Result.success(loginVO);
    }

    /**
     * 用户注册（种植户）
     */
    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterDTO registerDTO) {
        userService.register(registerDTO);
        return Result.success();
    }
}
