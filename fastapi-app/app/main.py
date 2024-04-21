from fastapi import FastAPI, HTTPException

app = FastAPI()


def is_fibonacci(n: int) -> bool:
    """
    Check if a number is a Fibonacci number.

    Args:
    n (int): The number to check.

    Returns:
    bool: True if n is a Fibonacci number, False otherwise.
    """
    x, y = 0, 1
    while x < n:
        x, y = y, x + y
    return x == n


def next_fibonacci(n: int) -> int:
    """
    Compute the next Fibonacci number after n.

    Args:
    n (int): The number to start from.

    Returns:
    int: The next Fibonacci number after n.
    """
    x, y = 0, 1
    while x <= n:
        x, y = y, x + y
    return x


@app.get("/fibonacci/{number}")
async def fibonacci(number: int) -> dict:
    """
    Endpoint to determine if a given number is a Fibonacci number
    and provide the next Fibonacci number if it is.

    Args:
    number (int): The number provided as a GET parameter.

    Returns:
    dict: A dictionary with the provided number and the next Fibonacci number,
          or an error message if the provided number is not a Fibonacci number.
    """
    if is_fibonacci(number):
        return {"number": number, "next_fibonacci": next_fibonacci(number)}
    raise HTTPException(status_code=404, detail="Not a Fibonacci number")
