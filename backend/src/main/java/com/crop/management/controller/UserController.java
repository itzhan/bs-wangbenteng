package com.crop.management.controller;

import com.crop.management.common.PageResult;
import com.crop.management.common.Result;
import com.crop.management.dto.PasswordDTO;
import com.crop.management.dto.UserDTO;
import com.crop.management.entity.User;
import com.crop.management.security.LoginUser;
import com.crop.management.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 获取当前登录用户
     */
    private LoginUser getCurrentUser() {
        return (LoginUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    /**
     * 分页查询用户列表
     */
    @GetMapping
    public Result<PageResult<User>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer role,
            @RequestParam(required = false) Integer status) {
        return Result.success(userService.list(page, size, keyword, role, status));
    }

    /**
     * 根据ID查询用户
     */
    @GetMapping("/{id}")
    public Result<User> getById(@PathVariable Long id) {
        return Result.success(userService.getById(id));
    }

    /**
     * 新增用户（管理员）
     */
    @PostMapping
    public Result<Void> create(@Valid @RequestBody UserDTO userDTO) {
        userService.create(userDTO);
        return Result.success();
    }

    /**
     * 修改用户
     */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody UserDTO userDTO) {
        userService.update(id, userDTO);
        return Result.success();
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return Result.success();
    }

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/current")
    public Result<User> getCurrentUserInfo() {
        LoginUser loginUser = getCurrentUser();
        return Result.success(userService.getCurrentUser(loginUser.getUserId()));
    }

    /**
     * 修改当前用户个人资料
     */
    @PutMapping("/current/profile")
    public Result<Void> updateProfile(@RequestBody UserDTO userDTO) {
        LoginUser loginUser = getCurrentUser();
        userService.updateProfile(loginUser.getUserId(), userDTO);
        return Result.success();
    }

    /**
     * 修改当前用户密码
     */
    @PutMapping("/current/password")
    public Result<Void> updatePassword(@Valid @RequestBody PasswordDTO passwordDTO) {
        LoginUser loginUser = getCurrentUser();
        userService.updatePassword(loginUser.getUserId(), passwordDTO);
        return Result.success();
    }
}
