local M = {}

M.on_save = function()
  local stack_info = vim.fn.getqflist({ nr = "$" })
  local max_nr = stack_info.nr or 0
  local history = {}
  
  for i = 1, max_nr do
    local qf = vim.fn.getqflist({ nr = i, items = 0, title = 1 })
    if qf and qf.items and #qf.items > 0 then
      local saved_items = {}
      
      for _, item in ipairs(qf.items) do
        table.insert(saved_items, {
          filename = item.bufnr and vim.api.nvim_buf_get_name(item.bufnr),
          module = item.module,
          lnum = item.lnum,
          end_lnum = item.end_lnum,
          col = item.col,
          end_col = item.end_col,
          vcol = item.vcol,
          nr = item.nr,
          pattern = item.pattern,
          text = item.text,
          type = item.type,
          valid = item.valid,
        })
      end

      table.insert(history, {
        title = qf.title or ("Liste " .. i),
        items = saved_items
      })
    end
  end
  return { history = history }
end

M.on_load = function(data)
  if not data or not data.history or #data.history == 0 then return end

  -- Empty current qflist.
  vim.fn.setqflist({}, 'r')

  for idx, qf in ipairs(data.history) do
    local action = (idx == 1) and 'r' or ' '
    vim.fn.setqflist({}, action, { title = qf.title, items = qf.items })
  end
end

--M.is_win_supported = function(winid, bufnr)
--  return vim.bo[bufnr].buftype == "quickfix"
--end
--
--M.save_win = function(winid)
--  return {}
--end
--
--M.load_win = function(winid, config)
--  vim.api.nvim_set_current_win(winid)
--  vim.cmd("copen")
--  vim.api.nvim_win_close(winid, true)
--  return vim.api.nvim_get_current_win()
--end
--
return M
