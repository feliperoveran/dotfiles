local ok_mason, mason = pcall(require, "mason")
if ok_mason then
  mason.setup()
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mason_lsp then
  mason_lspconfig.setup({
    ensure_installed = { "gopls", "ts_ls", "ruby_lsp", "pyright" },
  })
end

local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
if not ok_lspconfig then
  return
end

local function root_dir(bufnr, patterns)
  return vim.fs.root(bufnr, patterns) or vim.fn.getcwd()
end

lspconfig.gopls.setup({
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "go.work", "go.mod", ".git" })
  end,
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", ".git" })
  end,
})

local function ruby_lsp_cmd(bufnr)
  local root = root_dir(bufnr, { "Gemfile", ".git" })
  if root and vim.fn.executable("bundle") == 1 and vim.fn.filereadable(root .. "/Gemfile") == 1 then
    return { "bundle", "exec", "ruby-lsp" }
  end
  vim.notify("ruby-lsp: Gemfile/bundle not found, using global ruby-lsp", vim.log.levels.WARN)
  return { "ruby-lsp" }
end

lspconfig.ruby_lsp.setup({
  capabilities = capabilities,
  cmd = ruby_lsp_cmd,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "Gemfile", ".git" })
  end,
})

lspconfig.pyright.setup({
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
  end,
})

-- Format on save when the attached LSP supports it.
local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  callback = function()
    local ft = vim.bo.filetype
    if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
      return
    end

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ async = false })
        return
      end
    end
  end,
})
