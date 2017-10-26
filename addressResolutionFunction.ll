; ModuleID = 'addressResolutionFunction.c'
source_filename = "addressResolutionFunction.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12.0"

@levels = local_unnamed_addr constant i32 4, align 4
@offsetSize = local_unnamed_addr constant i32 8, align 4
@pteBitSize = local_unnamed_addr constant i32 64, align 4
@pageSize = local_unnamed_addr constant i32 2048, align 4
@rootTable = common local_unnamed_addr global i64* null, align 8
@.str = private unnamed_addr constant [27 x i8] c"Address for location 0: %p\00", align 1

; Function Attrs: nounwind ssp uwtable
define i64* @resolve(i64) local_unnamed_addr #0 {
  %2 = alloca [5 x i64], align 16
  %3 = bitcast [5 x i64]* %2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 40, i8* nonnull %3) #3
  call void @llvm.memset.p0i8.i64(i8* nonnull %3, i8 0, i64 40, i32 16, i1 false)
  br label %9

; <label>:4:                                      ; preds = %9
  %5 = load i64*, i64** @rootTable, align 8, !tbaa !3
  %6 = getelementptr inbounds [5 x i64], [5 x i64]* %2, i64 0, i64 4
  %7 = load i64, i64* %6, align 16, !tbaa !6
  %8 = getelementptr inbounds i64, i64* %5, i64 %7
  br label %17

; <label>:9:                                      ; preds = %9, %1
  %10 = phi i64 [ 0, %1 ], [ %14, %9 ]
  %11 = shl nsw i64 %10, 3
  %12 = ashr i64 %0, %11
  %13 = getelementptr inbounds [5 x i64], [5 x i64]* %2, i64 0, i64 %10
  store i64 %12, i64* %13, align 8, !tbaa !6
  %14 = add nuw nsw i64 %10, 1
  %15 = icmp eq i64 %14, 5
  br i1 %15, label %4, label %9

; <label>:16:                                     ; preds = %25
  call void @llvm.lifetime.end.p0i8(i64 40, i8* nonnull %3) #3
  ret i64* %31

; <label>:17:                                     ; preds = %4, %25
  %18 = phi i64* [ %8, %4 ], [ %31, %25 ]
  %19 = phi i64 [ 4, %4 ], [ %27, %25 ]
  %20 = load i64, i64* %18, align 8, !tbaa !6
  %21 = icmp eq i64 %20, 0
  br i1 %21, label %22, label %25

; <label>:22:                                     ; preds = %17
  %23 = tail call i8* @calloc(i64 2048, i64 1)
  %24 = ptrtoint i8* %23 to i64
  store i64 %24, i64* %18, align 8, !tbaa !6
  br label %25

; <label>:25:                                     ; preds = %17, %22
  %26 = bitcast i64* %18 to i64**
  %27 = add nsw i64 %19, -1
  %28 = load i64*, i64** %26, align 8, !tbaa !3
  %29 = getelementptr inbounds [5 x i64], [5 x i64]* %2, i64 0, i64 %27
  %30 = load i64, i64* %29, align 8, !tbaa !6
  %31 = getelementptr inbounds i64, i64* %28, i64 %30
  %32 = icmp eq i64 %27, 0
  br i1 %32, label %16, label %17
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: nounwind
declare noalias i8* @calloc(i64, i64) local_unnamed_addr #2

; Function Attrs: nounwind ssp uwtable
define i32 @main() local_unnamed_addr #0 {
  %1 = tail call i8* @calloc(i64 2048, i64 1)
  store i8* %1, i8** bitcast (i64** @rootTable to i8**), align 8, !tbaa !8
  %2 = tail call i64* @resolve(i64 0)
  %3 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str, i64 0, i64 0), i64* %2)
  ret i32 0
}

; Function Attrs: nounwind
declare i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #2

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 5.0.0 (tags/RELEASE_500/final)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"long", !4, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"any pointer", !4, i64 0}
