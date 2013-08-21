#--
# Copyright (c) 2013 Michael Berkovich, tr8nhub.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Tr8n
  module RulesEngine
    
    class Evaluator
      attr_reader :env, :vars

      def initialize
        @vars = {}
        @env = {
            # McCarthy's Elementary S-functions and Predicates
            "label" => lambda { |(l,r),     ctx| @env[l] = @vars[l] = r },
            "quote" => lambda { |(sexpr),   ctx| sexpr },
            "car"   => lambda { |(list),    ctx| list[0] },
            "cdr"   => lambda { |(list),    ctx| list.drop(1) },
            "cons"  => lambda { |(e,cell),  ctx| [e] + cell },
            "eq"    => lambda { |(l,r),     ctx| l == r },
            "atom"  => lambda { |(sexpr),   ctx| [Symbol, String, Fixnum, Float].include?(sexpr.class) },
            "cond"  => lambda { |(c, t, f), ctx| eval(c, ctx) ? eval(t, ctx) : eval(f, ctx) },

            # Tr8n Extensions
            "="       => lambda { |(l,r),     ctx| l == r },                                            # ["=", 1, 2]
            "!="      => lambda { |(l,r),     ctx| l != r },                                            # ["!=", 1, 2]
            "<"       => lambda { |(l,r),     ctx| l < r },                                             # ["<", 1, 2]
            ">"       => lambda { |(l,r),     ctx| l > r },                                             # [">", 1, 2]
            "+"       => lambda { |(l,r),     ctx| l + r },                                             # ["+", 1, 2]
            "-"       => lambda { |(l,r),     ctx| l - r },                                             # ["-", 1, 2]
            "*"       => lambda { |(l,r),     ctx| l * r },                                             # ["*", 1, 2]
            "%"       => lambda { |(l,r),     ctx| l % r },                                             # ["%", 14, 10]
            "/"       => lambda { |(l,r),     ctx| (l * 1.0) / r },                                     # ["/", 1, 2]
            "!"       => lambda { |(val),     ctx| not val },                                           # ["!", ["true"]]
            "&&"      => lambda { |(*sexpr),  ctx| sexpr.all?{|e| eval(e, ctx)}  },                     # ["&&", [], [], ...]
            "||"      => lambda { |(*sexpr),  ctx| sexpr.any?{|e| eval(e, ctx)} },                      # ["||", [], [], ...]
            "if"      => lambda { |(c, t, f), ctx| eval(c, ctx) ? eval(t, ctx) : eval(f, ctx) },        # ["if", "cond", "true", "false"]
            "let"     => lambda { |(l,r),     ctx| @env[l] = @vars[l] = r },                            # ["let", "n", 5]
            "and"     => lambda { |(*sexpr),  ctx| sexpr.all?{|e| eval(e, ctx)}  },                     # ["and", [], [], ...]
            "or"      => lambda { |(*sexpr),  ctx| sexpr.any?{|e| eval(e, ctx)} },                      # ["or", [], [], ...]
            "not"     => lambda { |(val),     ctx| not val },                                           # ["not", ["true"]]
            "mod"     => lambda { |(l,r),     ctx| l % r },                                             # ["mod", "n", 10]
            "append"  => lambda { |(l,r),     ctx| r.to_s + l.to_s},                                    # ["append", "world", "hello "]
            "prepend" => lambda { |(l,r),     ctx| l.to_s + r.to_s},                                    # ["prepend", "hello  ", "world"]
            "true"    => lambda { |(sexpr),   ctx| true },                                              # ["true"]
            "false"   => lambda { |(sexpr),   ctx| false },                                             # ["false"]
            "date"    => lambda { |(sexpr),   ctx| Date.strptime(sexpr, '%Y-%m-%d')},                   # ["date", "2010-01-01"]
            "today"   => lambda { |(sexpr),   ctx| Time.now.to_date},                                   # ["today"]
            "time"    => lambda { |(sexpr),   ctx| Time.strptime(sexpr, '%Y-%m-%d %H:%M:%S')},          # ["time", "2010-01-01 10:10:05"]
            "now"     => lambda { |(sexpr),   ctx| Time.now},                                           # ["now"]
            "match"   => lambda { |(l,r),     ctx|                                                      # ["match", /a/, "abc"]
              l = Regexp.new(/^\//.match(l) ? l[1..-2] : l) if l.is_a?(String)
              not l.match(r).nil?;
            },
            "in"      => lambda { |(l,r),     ctx|                                                      # ["in", "1,2,3,5..10,20..24", "@n"]
              r = r.to_s.strip
              l.split(',').each do |e|
                if e.index('..')
                  bounds = e.strip.split('..')
                  return true if (bounds.first.strip..bounds.last.strip).include?(r)
                end
                return true if e.strip == r
              end
              false
            },
            "within"  => lambda { |(l,r),     ctx|                                                      # ["within", "0..3", "n"]
              bounds = l.split('..').map{|d| Integer(d)}
              (bounds.first..bounds.last).include?(r)
            },
            "replace" => lambda { |(search,replace,subject),     ctx|                                   # ["replace", "/^a/", "v", "abc"]
              search = Regexp.new(/^\//.match(search) ? search[1..-2] : search) if search.is_a?(String)
              subject.gsub(search, replace)
            },
        }
      end

      def apply(fn, args, ctx=@env)
        raise "undefined symbols #{fn}" unless @env.keys.include?(fn)
        @env[fn].call(args, ctx)
      end

      def eval(sexpr, ctx=@env)
        if @env["atom"].call([sexpr], ctx)
          return ctx[sexpr] if ctx[sexpr]
          return sexpr
        end

        fn = sexpr[0]
        args = (sexpr.drop 1)
        unless ["quote", "cdr", "cond", "if", "&&", "||", "and", "or", "true", "false", "let"].member?(fn)
          args = args.map { |a| self.eval(a, ctx) }
        end
        apply(fn, args, ctx)
      end
    end

  end
end
