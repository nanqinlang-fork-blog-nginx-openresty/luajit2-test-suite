
-- 1.
do
  local x = 2
  for i=1,100 do
    local t = {}	-- TNEW: DCE
    x = t.foo		-- HREF -> niltv: folded
  end
  assert(x == nil)
end

-- 2.
do
  local x = 2
  for i=1,100 do
    local t = {1}	-- TDUP: DCE
    x = t.foo		-- HREF -> niltv: folded
  end
  assert(x == nil)
end

-- 3.
do
  local x = 2
  for i=1,100 do
    local t = {}
    t[1] = 11		-- NEWREF + HSTORE
    x = t[1]		-- AREF + ALOAD, no forwarding, no fold
  end
  assert(x == 11)
end

-- 4. HREFK not eliminated. Ditto for the EQ(FLOAD(t, #tab.hmask), k).
do
  local x = 2
  for i=1,100 do
    local t = {}
    t.foo = 11		-- NEWREF + HSTORE
    x = t.foo		-- HREFK + HLOAD: store forwarding
  end
  assert(x == 11)
end

-- 5. HREFK not eliminated. Ditto for the EQ(FLOAD(t, #tab.hmask), k).
do
  local x = 2
  for i=1,100 do
    local t = {foo=11}	-- TDUP
    x = t.foo		-- HREFK + non-nil HLOAD: folded
  end
  assert(x == 11)
end

-- 6.
do
  local x = 2
  local k = 1
  for i=1,100 do
    local t = {[0]=11}	-- TDUP
    t[k] = 22		-- AREF + ASTORE aliasing
    x = t[0]		-- AREF + ALOAD, no fold
  end
  assert(x == 11)
end

-- 7.
do
  local setmetatable = setmetatable
  local mt = { __newindex = function(t, k, v)
    assert(k == "foo")
    assert(v == 11)
  end }
  for i=1,100 do
    local t = setmetatable({}, mt)
    t.foo = 11
  end
end

