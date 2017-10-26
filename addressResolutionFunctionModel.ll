@str = constant [22 x i8] c"Resolved address: %d\0A\00"

define void @main() {
	%1 = call i64 @resolve(i40 0)
	call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @str, i32 0, i32 0), i64 %1)
	ret void
}

define i64 @resolve(i40 %num) {
	%baseMask8P = alloca i8
	store i8 -1, i8* %baseMask8P
	%baseMask8 = load i8, i8* %baseMask8P
	%baseMask = zext i8 %baseMask8 to i40

	%maskArrayPtr = alloca [5 x i40]
	%shamtP = alloca i8
	store i8 0, i8* %shamtP
	%shamt = load i8, i8* %shamtP

	MaskConstructionLoopBody:
	%

	ret i64 0
}

declare i32 @printf(i8*, ...)