types_raw = [
	"Binary   : Expr left, Token op, Expr right",
	"Grouping : Expr expression",
	"Literal  : Any value",
	"Unary    : Token op, Expr right",
]

basename = "Expr"

types = []
for t in types_raw:
	classname, fields_raw = [part.strip() for part in t.split(":")]

	fields = []
	for f in fields_raw.split(", "):
		field_type, field_name = [part.strip() for part in f.split(" ")]
		fields.append((field_type, field_name))
	types.append((classname, fields))

# Visitor interace
print("protocol ExprVisitor {")
for (n, _) in types:
	lowerbase = basename.lower()
	print("    func visit<T>(_ {lowerbase}: {n}) -> T".format(**locals()))
print("}")

print()

print("protocol {basename} {{".format(**locals()))
print("    func accept<T>(_ visitor: ExprVisitor) -> T")
print("}")

for (classname, fields) in types:
	print()
	print("class {classname}: {basename} {{".format(**locals()))
	
	for (field_type, field_name) in fields:
		print("    let {field_name}: {field_type}".format(**locals()))
	
	signature = ", ".join(["_ {n}: {t}".format(t=t, n=n) for (t, n) in fields])
	print()
	print("    init({signature}) {{".format(**locals()))
	

	[print("        self.{n} = {n}".format(n=n)) for (_, n) in fields]
	print("    }")
	
	# Visitor pattern
	print()
	print("    func accept<T>(_ visitor: ExprVisitor) -> T {")
	print("        return visitor.visit(self)".format(**locals()))
	print("    }")

	print("}")
