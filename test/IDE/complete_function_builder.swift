// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=IN_CLOSURE_TOP | %FileCheck %s -check-prefix=IN_CLOSURE_TOP
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=IN_CLOSURE_NONTOP | %FileCheck %s -check-prefix=IN_CLOSURE_TOP
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=IN_CLOSURE_COLOR_CONTEXT | %FileCheck %s -check-prefix=IN_CLOSURE_COLOR_CONTEXT
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=IN_FUNCTION_BUILDER_DECL -code-completion-comments=true | %FileCheck %s -check-prefix=IN_FUNCTION_BUILDER_DECL

struct Tagged<Tag, Entity> {
  let tag: Tag
  let entity: Entity

  static func fo
}

protocol Taggable {
}

extension Taggable {
  func tag<Tag>(_ tag: Tag) -> Tagged<Tag, Self> {
    return Tagged(tag: tag, entity: self)
  }
}

extension Int: Taggable { }
extension String: Taggable { }

@_functionBuilder
struct TaggedBuilder<Tag> {
  static func buildBlock() -> () { }

  static func buildBlock<T1>(_ t1: Tagged<Tag, T1>) -> Tagged<Tag, T1> {
    return t1
  }

  static func buildBlock<T1, T2>(_ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>) -> (Tagged<Tag, T1>, Tagged<Tag, T2>) {
    return (t1, t2)
  }
  static func buildBlock<T1, T2, T3>(_ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>, _ t2: Tagged<Tag, T3>) -> (Tagged<Tag, T1>, Tagged<Tag, T2>, Tagged<Tag, T3>) {
    return (t1, t2, t3)
  }
}

enum Color {
  case red, green, blue
}

func acceptColorTagged<Result>(@TaggedBuilder<Color> body: (Color) -> Result) {
  print(body(.blue))
}

var globalIntVal: Int = 1
let globalStringVal: String = ""

func testAcceptColorTagged(paramIntVal: Int, paramStringVal: String) {

  let taggedValue = paramIntVal.tag(Color.red)

  acceptColorTagged { color in
    #^IN_CLOSURE_TOP^#
// IN_CLOSURE_TOP_CONTEXT: Begin completions
// IN_CLOSURE_TOP-DAG: Decl[LocalVar]/Local{{.*}}:               taggedValue[#Tagged<Color, Int>#]; name=taggedValue
// IN_CLOSURE_TOP-DAG: Decl[GlobalVar]/CurrModule:         globalIntVal[#Int#]; name=globalIntVal
// IN_CLOSURE_TOP-DAG: Decl[GlobalVar]/CurrModule:         globalStringVal[#String#]; name=globalStringVal
// IN_CLOSURE_TOP-DAG: Decl[LocalVar]/Local:               color{{.*}}; name=color
// IN_CLOSURE_TOP-DAG: Decl[LocalVar]/Local:               paramIntVal[#Int#]; name=paramIntVal
// IN_CLOSURE_TOP-DAG: Decl[LocalVar]/Local:               paramStringVal[#String#]; name=paramStringVal
// IN_CLOSURE_TOP: End completions
  }

  acceptColorTagged { color in
    paramIntVal.tag(.red)
    #^IN_CLOSURE_NONTOP^#
// Same as IN_CLOSURE_TOP.
  }

  acceptColorTagged { color in
    paramIntVal.tag(#^IN_CLOSURE_COLOR_CONTEXT^#)
// IN_CLOSURE_COLOR_CONTEXT: Begin completions
// IN_CLOSURE_COLOR_CONTEXT-DAG: Decl[LocalVar]/Local:               color; name=color
// IN_CLOSURE_COLOR_CONTEXT-DAG: Decl[LocalVar]/Local:               taggedValue[#Tagged<Color, Int>#]; name=taggedValue
// IN_CLOSURE_COLOR_CONTEXT-DAG: Decl[LocalVar]/Local:               paramIntVal[#Int#]; name=paramIntVal
// IN_CLOSURE_COLOR_CONTEXT-DAG: Decl[LocalVar]/Local:               paramStringVal[#String#]; name=paramStringVal
// IN_CLOSURE_COLOR_CONTEXT: End completions
  }
}

enum MyEnum {
  case east, west
  case north, south
}
@_functionBuilder
struct EnumToVoidBuilder {
  static func buildBlock() {}
  static func buildBlock(_ :MyEnum) {}
  static func buildBlock(_ :MyEnum, _: MyEnum) {}
  static func buildBlock(_ :MyEnum, _: MyEnum, _: MyEnum) {}
}
func acceptBuilder(@EnumToVoidBuilder body: () -> Void) {}

@_functionBuilder
struct AnyBuilder {
  static func buildBlock(_ components: Any...) -> Any { 5 }

  static func #^IN_FUNCTION_BUILDER_DECL^#
}

// IN_FUNCTION_BUILDER_DECL: Begin completions, 8 items
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildBlock(_ components: Any...) -> Any { {|}; name=buildBlock(_ components: Any...) -> Any {; comment=Required by every
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildExpression(_ expression: <#Expression#>) -> Any { {|}; name=buildExpression(_ expression: <#Expression#>) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildOptional(_ component: Any?) -> Any { {|}; name=buildOptional(_ component: Any?) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildEither(first component: Any) -> Any { {|}; name=buildEither(first component: Any) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildEither(second component: Any) -> Any { {|}; name=buildEither(second component: Any) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildArray(_ components: [Any]) -> Any { {|}; name=buildArray(_ components: [Any]) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildLimitedAvailability(_ component: Any) -> Any { {|}; name=buildLimitedAvailability(_ component: Any) -> Any {; comment=
// IN_FUNCTION_BUILDER_DECL: Pattern/CurrNominal:                buildFinalResult(_ component: Any) -> <#Result#> {|}; name=buildFinalResult(_ component: Any) -> <#Result#>; comment=
// IN_FUNCTION_BUILDER_DECL: End completions
