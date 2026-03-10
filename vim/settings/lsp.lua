-- Map filetypes to LSP servers.
-- To add a new one: add the filetype + server here and add a matching configure() block below.
local ft_to_server = {
  go = "gopls",
  javascript = "ts_ls",
  javascriptreact = "ts_ls",
  typescript = "ts_ls",
  typescriptreact = "ts_ls",
  json = "ts_ls",
  jsonc = "ts_ls",
  ruby = "ruby_lsp",
  python = "pyright",
  cs = "omnisharp",
  lua = "lua_ls",
}

-- Neovim 0.11+ native LSP config
local function configure(server, config)
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

vim.lsp.set_log_level("error")

local function root_dir(bufnr, patterns)
  return vim.fs.root(bufnr, patterns) or vim.fn.getcwd()
end

local function ruby_lsp_cmd(bufnr)
  local root = root_dir(bufnr, { "Gemfile", ".git" })
  if root and vim.fn.executable("bundle") == 1 and vim.fn.filereadable(root .. "/Gemfile") == 1 then
    return { "bundle", "exec", "ruby-lsp" }
  end
  vim.notify("ruby-lsp: Gemfile/bundle not found, using global ruby-lsp", vim.log.levels.WARN)
  return { "ruby-lsp" }
end

-- Only filetypes that have an LSP mapping are auto-formatted on save.
local function format_on_save_enabled(ft)
  return ft_to_server[ft] ~= nil
end

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
  mason_lspconfig.setup()
end

configure("gopls", {
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "go.work", "go.mod", ".git" })
  end,
})

configure("ts_ls", {
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", ".git" })
  end,
})

configure("ruby_lsp", {
  capabilities = capabilities,
  cmd = ruby_lsp_cmd,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "Gemfile", ".git" })
  end,
})

configure("pyright", {
  capabilities = capabilities,
  root_dir = function(bufnr)
    return root_dir(bufnr, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
  end,
})

configure("omnisharp", {
  capabilities = capabilities,
  cmd = {
    vim.fn.stdpath("data") .. "/mason/bin/omnisharp",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
  },
  root_dir = function(bufnr)
    return root_dir(bufnr, { "*.sln", "*.csproj", ".git" })
  end,
})

-- Format on save when the attached LSP supports it.
local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  callback = function()
    local ft = vim.bo.filetype
    if not format_on_save_enabled(ft) then
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

-- Warn only when opening a filetype whose LSP server isn't installed.
local warned_missing = {}
local ok_registry, registry = pcall(require, "mason-registry")
if ok_registry then
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local server = ft_to_server[vim.bo[args.buf].filetype]
      if not server or warned_missing[server] then
        return
      end

      local ok_pkg, pkg = pcall(registry.get_package, server)
      if ok_pkg and not pkg:is_installed() then
        warned_missing[server] = true
        vim.notify(
          "Missing LSP server '" .. server .. "'. Install with :MasonInstall " .. server,
          vim.log.levels.WARN
        )
      end
    end,
  })
end
