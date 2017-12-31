; ModuleID = 'main'
source_filename = "main"

@rootPt = global i64* null
@curRegPtr = global i40 0
@0 = private unnamed_addr constant [3 x i8] c"%c\00"

declare i32 @printf(i8*, ...)

declare i8* @calloc(i64, i64)

declare i32 @getchar()

define i64* @resolve(i40) {
entry:
  %1 = alloca [5 x i8]
  %2 = alloca i8
  store i8 0, i8* %2
  br label %offsetBuilderLoop

offsetBuilderLoop:                                ; preds = %offsetBuilderLoop, %entry
  %3 = load i8, i8* %2
  %4 = zext i8 %3 to i40
  %5 = mul i40 %4, 8
  %6 = lshr i40 %0, %5
  %7 = trunc i40 %6 to i8
  %8 = getelementptr [5 x i8], [5 x i8]* %1, i8 0, i8 %3
  store i8 %7, i8* %8
  %9 = add i8 %3, 1
  store i8 %9, i8* %2
  %10 = icmp eq i8 %9, 5
  br i1 %10, label %resolutionInit, label %offsetBuilderLoop

resolutionInit:                                   ; preds = %offsetBuilderLoop
  %11 = alloca i64*
  %12 = getelementptr [5 x i8], [5 x i8]* %1, i8 0, i8 4
  %13 = load i8, i8* %12
  %14 = load i64*, i64** @rootPt
  %15 = getelementptr i64, i64* %14, i8 %13
  store i8 3, i8* %2
  store i64* %15, i64** %11
  br label %resolutionLoop

resolutionLoop:                                   ; preds = %resolutionLoopEnd, %resolutionInit
  %16 = load i64*, i64** %11
  %17 = load i8, i8* %2
  %18 = load i64, i64* %16
  %19 = icmp eq i64 %18, 0
  br i1 %19, label %callocCondition, label %resolutionLoopEnd

callocCondition:                                  ; preds = %resolutionLoop
  %20 = call i8* @calloc(i64 2048, i64 1)
  %21 = ptrtoint i8* %20 to i64
  store i64 %21, i64* %16
  br label %resolutionLoopEnd

resolutionLoopEnd:                                ; preds = %callocCondition, %resolutionLoop
  %22 = bitcast i64* %16 to i64**
  %23 = add i8 %17, -1
  %24 = load i64*, i64** %22
  %25 = getelementptr [5 x i8], [5 x i8]* %1, i8 0, i8 %23
  %26 = load i8, i8* %25
  %27 = getelementptr i64, i64* %24, i8 %26
  store i64* %27, i64** %11
  store i8 %23, i8* %2
  %28 = icmp eq i8 %23, 0
  br i1 %28, label %ret, label %resolutionLoop

ret:                                              ; preds = %resolutionLoopEnd
  ret i64* %27
}

define void @main() {
entry:
  %0 = call i8* @calloc(i64 2048, i64 1)
  %1 = bitcast i8* %0 to i64*
  store i64* %1, i64** @rootPt
  %2 = load i40, i40* @curRegPtr
  %3 = add i40 %2, 1
  store i40 %3, i40* @curRegPtr
  %4 = load i40, i40* @curRegPtr
  %5 = call i64* @resolve(i40 %4)
  %6 = load i64, i64* %5
  %7 = add i64 %6, 7
  store i64 %7, i64* %5
  br label %RoflCond

RoflCond:                                         ; preds = %RoflBody, %entry
  %8 = load i40, i40* @curRegPtr
  %9 = call i64* @resolve(i40 %8)
  %10 = load i64, i64* %9
  %11 = icmp eq i64 %10, 0
  br i1 %11, label %Copter, label %RoflBody

RoflBody:                                         ; preds = %RoflCond
  %12 = load i40, i40* @curRegPtr
  %13 = call i64* @resolve(i40 %12)
  %14 = load i64, i64* %13
  %15 = add i64 %14, -1
  store i64 %15, i64* %13
  %16 = load i40, i40* @curRegPtr
  %17 = add i40 %16, -1
  store i40 %17, i40* @curRegPtr
  %18 = load i40, i40* @curRegPtr
  %19 = call i64* @resolve(i40 %18)
  %20 = load i64, i64* %19
  %21 = add i64 %20, 10
  store i64 %21, i64* %19
  %22 = load i40, i40* @curRegPtr
  %23 = add i40 %22, 1
  store i40 %23, i40* @curRegPtr
  br label %RoflCond

Copter:                                           ; preds = %RoflCond
  %24 = load i40, i40* @curRegPtr
  %25 = add i40 %24, -1
  store i40 %25, i40* @curRegPtr
  %26 = load i40, i40* @curRegPtr
  %27 = call i64* @resolve(i40 %26)
  %28 = load i64, i64* %27
  %29 = add i64 %28, 2
  store i64 %29, i64* %27
  %30 = load i40, i40* @curRegPtr
  %31 = call i64* @resolve(i40 %30)
  %32 = load i64, i64* %31
  %33 = call i64* @resolve(i40 1)
  store i64 %32, i64* %33
  store i40 1, i40* @curRegPtr
  %34 = load i40, i40* @curRegPtr
  %35 = call i64* @resolve(i40 %34)
  %36 = load i64, i64* %35
  %37 = add i64 %36, -3
  store i64 %37, i64* %35
  store i40 0, i40* @curRegPtr
  %38 = load i40, i40* @curRegPtr
  %39 = call i64* @resolve(i40 %38)
  %40 = load i64, i64* %39
  %41 = call i64* @resolve(i40 2)
  store i64 %40, i64* %41
  store i40 2, i40* @curRegPtr
  %42 = load i40, i40* @curRegPtr
  %43 = call i64* @resolve(i40 %42)
  %44 = load i64, i64* %43
  %45 = add i64 %44, 4
  store i64 %45, i64* %43
  %46 = load i40, i40* @curRegPtr
  %47 = call i64* @resolve(i40 %46)
  %48 = load i64, i64* %47
  %49 = call i64* @resolve(i40 3)
  store i64 %48, i64* %49
  store i40 3, i40* @curRegPtr
  %50 = load i40, i40* @curRegPtr
  %51 = call i64* @resolve(i40 %50)
  %52 = load i64, i64* %51
  %53 = call i64* @resolve(i40 4)
  store i64 %52, i64* %53
  store i40 4, i40* @curRegPtr
  %54 = load i40, i40* @curRegPtr
  %55 = call i64* @resolve(i40 %54)
  %56 = load i64, i64* %55
  %57 = add i64 %56, 3
  store i64 %57, i64* %55
  %58 = load i40, i40* @curRegPtr
  %59 = add i40 %58, 1
  store i40 %59, i40* @curRegPtr
  %60 = load i40, i40* @curRegPtr
  %61 = add i40 %60, 1
  store i40 %61, i40* @curRegPtr
  %62 = load i40, i40* @curRegPtr
  %63 = call i64* @resolve(i40 %62)
  %64 = load i64, i64* %63
  %65 = add i64 %64, 4
  store i64 %65, i64* %63
  br label %RoflCond1

RoflCond1:                                        ; preds = %RoflBody2, %Copter
  %66 = load i40, i40* @curRegPtr
  %67 = call i64* @resolve(i40 %66)
  %68 = load i64, i64* %67
  %69 = icmp eq i64 %68, 0
  br i1 %69, label %Copter3, label %RoflBody2

RoflBody2:                                        ; preds = %RoflCond1
  %70 = load i40, i40* @curRegPtr
  %71 = call i64* @resolve(i40 %70)
  %72 = load i64, i64* %71
  %73 = add i64 %72, -1
  store i64 %73, i64* %71
  %74 = load i40, i40* @curRegPtr
  %75 = add i40 %74, -1
  store i40 %75, i40* @curRegPtr
  %76 = load i40, i40* @curRegPtr
  %77 = call i64* @resolve(i40 %76)
  %78 = load i64, i64* %77
  %79 = add i64 %78, 8
  store i64 %79, i64* %77
  %80 = load i40, i40* @curRegPtr
  %81 = add i40 %80, 1
  store i40 %81, i40* @curRegPtr
  br label %RoflCond1

Copter3:                                          ; preds = %RoflCond1
  store i40 4, i40* @curRegPtr
  %82 = load i40, i40* @curRegPtr
  %83 = call i64* @resolve(i40 %82)
  %84 = load i64, i64* %83
  %85 = call i64* @resolve(i40 6)
  store i64 %84, i64* %85
  store i40 6, i40* @curRegPtr
  %86 = load i40, i40* @curRegPtr
  %87 = call i64* @resolve(i40 %86)
  %88 = load i64, i64* %87
  %89 = add i64 %88, 8
  store i64 %89, i64* %87
  store i40 4, i40* @curRegPtr
  %90 = load i40, i40* @curRegPtr
  %91 = call i64* @resolve(i40 %90)
  %92 = load i64, i64* %91
  %93 = call i64* @resolve(i40 7)
  store i64 %92, i64* %93
  store i40 7, i40* @curRegPtr
  %94 = load i40, i40* @curRegPtr
  %95 = call i64* @resolve(i40 %94)
  %96 = load i64, i64* %95
  %97 = call i64* @resolve(i40 8)
  store i64 %96, i64* %97
  store i40 8, i40* @curRegPtr
  %98 = load i40, i40* @curRegPtr
  %99 = call i64* @resolve(i40 %98)
  %100 = load i64, i64* %99
  %101 = add i64 %100, 3
  store i64 %101, i64* %99
  store i40 4, i40* @curRegPtr
  %102 = load i40, i40* @curRegPtr
  %103 = call i64* @resolve(i40 %102)
  %104 = load i64, i64* %103
  %105 = call i64* @resolve(i40 9)
  store i64 %104, i64* %105
  store i40 9, i40* @curRegPtr
  %106 = load i40, i40* @curRegPtr
  %107 = call i64* @resolve(i40 %106)
  %108 = load i64, i64* %107
  %109 = add i64 %108, -3
  store i64 %109, i64* %107
  store i40 1, i40* @curRegPtr
  %110 = load i40, i40* @curRegPtr
  %111 = call i64* @resolve(i40 %110)
  %112 = load i64, i64* %111
  %113 = call i64* @resolve(i40 10)
  store i64 %112, i64* %113
  store i40 10, i40* @curRegPtr
  %114 = load i40, i40* @curRegPtr
  %115 = call i64* @resolve(i40 %114)
  %116 = load i64, i64* %115
  %117 = add i64 %116, -1
  store i64 %117, i64* %115
  %118 = load i40, i40* @curRegPtr
  %119 = add i40 %118, 1
  store i40 %119, i40* @curRegPtr
  %120 = load i40, i40* @curRegPtr
  %121 = call i64* @resolve(i40 %120)
  %122 = load i64, i64* %121
  %123 = add i64 %122, 10
  store i64 %123, i64* %121
  store i40 0, i40* @curRegPtr
  br label %RoflCond4

RoflCond4:                                        ; preds = %RoflBody5, %Copter3
  %124 = load i40, i40* @curRegPtr
  %125 = call i64* @resolve(i40 %124)
  %126 = load i64, i64* %125
  %127 = icmp eq i64 %126, 0
  br i1 %127, label %Copter6, label %RoflBody5

RoflBody5:                                        ; preds = %RoflCond4
  %128 = load i40, i40* @curRegPtr
  %129 = call i64* @resolve(i40 %128)
  %130 = load i64, i64* %129
  %131 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i64 %130)
  %132 = load i40, i40* @curRegPtr
  %133 = add i40 %132, 1
  store i40 %133, i40* @curRegPtr
  br label %RoflCond4

Copter6:                                          ; preds = %RoflCond4
  ret void
}
