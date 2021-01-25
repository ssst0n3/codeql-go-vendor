/**
 * Provides classes for working with concepts from the [`clevergo.tech/clevergo@v0.5.2`](https://pkg.go.dev/clevergo.tech/clevergo@v0.5.2) package.
 */

import go

/**
 * Provides classes for working with concepts from the [`clevergo.tech/clevergo@v0.5.2`](https://pkg.go.dev/clevergo.tech/clevergo@v0.5.2) package.
 */
private module CleverGo {
  /** Gets the package path. */
  bindingset[result]
  string packagePath() {
    result = package(["clevergo.tech/clevergo", "github.com/clevergo/clevergo"], "")
  }

  /**
   * Provides models of untrusted flow sources.
   */
  private class UntrustedSources extends UntrustedFlowSource::Range {
    UntrustedSources() {
      // Methods on types of package: clevergo.tech/clevergo@v0.5.2
      exists(string receiverName, string methodName, Method mtd, FunctionOutput out |
        this = out.getExitNode(mtd.getACall()) and
        mtd.hasQualifiedName(packagePath(), receiverName, methodName)
      |
        receiverName = "Context" and
        (
          // signature: func (*Context).BasicAuth() (username string, password string, ok bool)
          methodName = "BasicAuth" and
          out.isResult([0, 1])
          or
          // signature: func (*Context).Decode(v interface{}) (err error)
          methodName = "Decode" and
          out.isParameter(0)
          or
          // signature: func (*Context).DefaultQuery(key string, defaultVlue string) string
          methodName = "DefaultQuery" and
          out.isResult()
          or
          // signature: func (*Context).FormValue(key string) string
          methodName = "FormValue" and
          out.isResult()
          or
          // signature: func (*Context).GetHeader(name string) string
          methodName = "GetHeader" and
          out.isResult()
          or
          // signature: func (*Context).PostFormValue(key string) string
          methodName = "PostFormValue" and
          out.isResult()
          or
          // signature: func (*Context).QueryParam(key string) string
          methodName = "QueryParam" and
          out.isResult()
          or
          // signature: func (*Context).QueryString() string
          methodName = "QueryString" and
          out.isResult()
        )
        or
        receiverName = "Params" and
        (
          // signature: func (Params).String(name string) string
          methodName = "String" and
          out.isResult()
        )
      )
      or
      // Interfaces of package: clevergo.tech/clevergo@v0.5.2
      exists(string interfaceName, string methodName, Method mtd, FunctionOutput out |
        this = out.getExitNode(mtd.getACall()) and
        mtd.implements(packagePath(), interfaceName, methodName)
      |
        interfaceName = "Decoder" and
        (
          // signature: func (Decoder).Decode(req *net/http.Request, v interface{}) error
          methodName = "Decode" and
          out.isParameter(1)
        )
      )
      or
      // Structs of package: clevergo.tech/clevergo@v0.5.2
      exists(string structName, string fields, DataFlow::Field fld |
        this = fld.getARead() and
        fld.hasQualifiedName(packagePath(), structName, fields)
      |
        structName = "Context" and
        fields = "Params"
        or
        structName = "Param" and
        fields = ["Key", "Value"]
      )
      or
      // Types of package: clevergo.tech/clevergo@v0.5.2
      exists(ValueEntity v | v.getType().hasQualifiedName(packagePath(), "Params") |
        this = v.getARead()
      )
    }
  }

  // Models taint-tracking through functions.
  private class TaintTrackingFunctionModels extends TaintTracking::FunctionModel {
    FunctionInput inp;
    FunctionOutput out;

    TaintTrackingFunctionModels() {
      // Taint-tracking models for package: clevergo.tech/clevergo@v0.5.2
      (
        // signature: func CleanPath(p string) string
        this.hasQualifiedName(packagePath(), "CleanPath") and
        inp.isParameter(0) and
        out.isResult()
      )
    }

    override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
      input = inp and output = out
    }
  }

  // Models taint-tracking through method calls.
  private class TaintTrackingMethodModels extends TaintTracking::FunctionModel, Method {
    FunctionInput inp;
    FunctionOutput out;

    TaintTrackingMethodModels() {
      // Taint-tracking models for package: clevergo.tech/clevergo@v0.5.2
      (
        // Receiver type: Application
        // signature: func (*Application).RouteURL(name string, args ...string) (*net/url.URL, error)
        this.hasQualifiedName(packagePath(), "Application", "RouteURL") and
        inp.isParameter(_) and
        out.isResult(0)
        or
        // Receiver interface: Decoder
        // signature: func (Decoder).Decode(req *net/http.Request, v interface{}) error
        this.implements(packagePath(), "Decoder", "Decode") and
        inp.isParameter(0) and
        out.isParameter(1)
        or
        // Receiver interface: Renderer
        // signature: func (Renderer).Render(w io.Writer, name string, data interface{}, c *Context) error
        this.implements(packagePath(), "Renderer", "Render") and
        inp.isParameter(2) and
        out.isParameter(0)
      )
    }

    override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
      input = inp and output = out
    }
  }

  // Models HTTP redirects.
  private class HttpRedirect extends HTTP::Redirect::Range, DataFlow::CallNode {
    string package;
    DataFlow::Node urlNode;

    HttpRedirect() {
      // HTTP redirect models for package: clevergo.tech/clevergo@v0.5.2
      package = packagePath() and
      // Receiver type: Context
      (
        // signature: func (*Context).Redirect(code int, url string) error
        this = any(Method m | m.hasQualifiedName(package, "Context", "Redirect")).getACall() and
        urlNode = this.getArgument(1)
      )
    }

    override DataFlow::Node getUrl() { result = urlNode }

    override HTTP::ResponseWriter getResponseWriter() { none() }
  }
}
