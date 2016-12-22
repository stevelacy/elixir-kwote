defmodule Quote do
  @derive [Poison.Encoder]
  defstruct [:content, :title]
end

defmodule Kwote do
  @doc ~S"""
    **A simple CLI app for returning a Quote from**
    [Quotes on Design](http://quotesondesign.com)

    ## Examples

        Return a random quote
        $ ./kwote --random

        Return the same first indexing quote
        $ ./kwote
  """
  use HTTPoison.Base

  def sourceURL, do: "http://quotesondesign.com/wp-json/posts"

  def main(args) do
    args |> parse_args |> process |> ok |> parse_result
  end

  defp ok({:ok, result}), do: result

  def process([]) do
    IO.puts "No arguments given"

    get!(sourceURL)
    |> Map.get(:body)
    |> Poison.decode
  end

  def process(options) do
    IO.puts options[:type]
    get!("#{sourceURL}?filter[orderby]=rand")
    |> Map.get(:body)
    |> Poison.decode
  end

  def parse_result(body) do
    content = List.first(body)["content"]
      |> String.replace(~r/<br?.?\/?>?\s/, "\n")
      |> String.replace(~r/<[^>]*>/, "", global: true)
    IO.puts content
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [type: :string]
    )
    options
  end
end
