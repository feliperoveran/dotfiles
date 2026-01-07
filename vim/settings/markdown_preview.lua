local function markdown_preview()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local html = dir .. "/vim-markdown-preview.html"
  local cmd

  if vim.fn.executable("grip") == 1 then
    cmd = string.format("grip %s --export %s --title vim-markdown-preview.html", vim.fn.shellescape(file), vim.fn.shellescape(html))
  elseif vim.fn.executable("pandoc") == 1 then
    cmd = string.format("pandoc --standalone %s > %s", vim.fn.shellescape(file), vim.fn.shellescape(html))
  elseif vim.fn.executable("markdown") == 1 then
    cmd = string.format("markdown %s > %s", vim.fn.shellescape(file), vim.fn.shellescape(html))
  else
    vim.notify("No markdown renderer found (grip/pandoc/markdown)", vim.log.levels.WARN)
    return
  end

  vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Markdown preview failed", vim.log.levels.WARN)
    return
  end

  if vim.fn.has("wsl") == 1 and vim.fn.executable("wslpath") == 1 and vim.fn.executable("cmd.exe") == 1 then
    local winpath = vim.fn.systemlist("wslpath -w " .. vim.fn.shellescape(html))[1] or ""
    if winpath ~= "" then
      vim.fn.system(string.format('cmd.exe /c start "" %s 1>/dev/null 2>/dev/null &', vim.fn.shellescape(winpath)))
      return
    end
  end

  if vim.fn.executable("wslview") == 1 then
    vim.fn.system(string.format("wslview %s 1>/dev/null 2>/dev/null &", vim.fn.shellescape(html)))
  elseif vim.fn.executable("xdg-open") == 1 then
    vim.fn.system(string.format("xdg-open %s 1>/dev/null 2>/dev/null &", vim.fn.shellescape(html)))
  elseif vim.fn.executable("see") == 1 then
    vim.fn.system(string.format("see %s 1>/dev/null 2>/dev/null &", vim.fn.shellescape(html)))
  else
    vim.notify("No opener found (wslview/xdg-open/see)", vim.log.levels.WARN)
  end
end

local group = vim.api.nvim_create_augroup("MarkdownPreviewOverride", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "md" },
  callback = function()
    vim.keymap.set("n", "<C-o>", markdown_preview, { buffer = true, silent = true })
  end,
})
