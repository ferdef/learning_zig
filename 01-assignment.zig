const constant: i32 = 5;
var variable: u32 = 5000;

const inferred_constant = @as(i32, variable);
var inferred_variable = @as(u32, constant);

const a: i32 = undefined;
const b: u32 = undefined;
