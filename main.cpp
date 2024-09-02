#include <vector> // vector
#include <iostream> // cout
#include <cstdlib> // rand();
#include <thread> // thread (so input can be on a separate thread)
#include <chrono> // with thread this allows OS unlocked sleep

// needs to be up here since it's handy for the `Dimensions` function
class Point {
public:
	int x, y;
	Point(int x, int y) : x(x), y(y) {}
};

// platform compatibility
#ifdef _WIN32
#include <Windows.h> // console stuff
#include <conio.h> // _getch();
#define getch _getch

void HideCursor() {
	HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);

	CONSOLE_CURSOR_INFO cursorInfo;

	GetConsoleCursorInfo(out, &cursorInfo);
	cursorInfo.bVisible = false;
	SetConsoleCursorInfo(out, &cursorInfo);
}

void RepositionCursor() {
	static const HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	std::cout.flush();
	SetConsoleCursorPosition(hOut, { 0, 0 });
}

Point Dimensions() {
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
	return Point(csbi.srWindow.Right - csbi.srWindow.Left + 1, csbi.srWindow.Bottom - csbi.srWindow.Top + 1);
}
#elif __linux__
#include <unistd.h> // console stuff
#include <termios.h>
int getch() 
{
		struct termios oldattr, newattr;
		tcgetattr(STDIN_FILENO, &oldattr);
		newattr = oldattr;
		newattr.c_lflag &= ~(ICANON | ECHO);
		tcsetattr(STDIN_FILENO, TCSANOW, &newattr);
		int ch = getchar();
		tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);
		return ch;
} 
#elif __APPLE__ // or __MACH__
#include <curses.h> // getch();
#endif

#if __linux__ || __APPLE__
void HideCursor() {
	std::cout << "\033[?25l";
}

void RepositionCursor() {
	std::cout << "\033[<0>;<0>H";
}

#include <sys/ioctl.h>
Point Dimensions() {
	struct winsize ws;
	ioctl(fileno(stdout), TIOCGWINSZ, &ws);
	return Point((int)(ws.ws_col), (int)(ws.ws_row));
}
#endif
// platform unlocked sleep
void sleep(int milliseconds) {
	std::this_thread::sleep_for(std::chrono::milliseconds(milliseconds));
}

// might need to look into Linux versions :shrug:
#define ARROW_UP 72
#define ARROW_DOWN 80
#define ARROW_LEFT 75
#define ARROW_RIGHT 77

void SplashScreen(int half_width) {
	std::string dashes = std::string(half_width - 8, '-');
	std::cout << dashes << " Console Snake " << dashes << std::endl;
	int THROWAWAY = getch();
}

void ScoreScreen(int score, int half_width, int half_height) {
	for (int i = 0; i < half_height - 1; i++) {
		std::cout << std::endl;
	}
	std::string dashes = std::string(half_width - 9, '-');
	std::cout << dashes << " Game Over! " << dashes << std::endl;
	std::cout << dashes << " Your score: " << score << " " << dashes << std::endl;
	int THROWAWAY = getch();
}

enum Direction {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
};
Direction prev_dir = NONE;
Direction dir = NONE;

void input_loop() {
	// infinite input loop
	while (true) {
		// direction changes
		switch (getch()) {
		case ARROW_UP:
		case 'W':
		case 'w':
			if (prev_dir == NONE || prev_dir == LEFT || prev_dir == RIGHT) {
				dir = UP;
			}
			break;
		case ARROW_DOWN:
		case 'S':
		case 's':
			if (prev_dir == NONE || prev_dir == LEFT || prev_dir == RIGHT) {
				dir = DOWN;
			}
			break;
		case ARROW_LEFT:
		case 'A':
		case 'a':
			if (prev_dir == NONE || prev_dir == UP || prev_dir == DOWN) {
				dir = LEFT;
			}
			break;
		case ARROW_RIGHT:
		case 'D':
		case 'd':
			if (prev_dir == NONE || prev_dir == UP || prev_dir == DOWN) {
				dir = RIGHT;
			}
			break;
		default:
			break;
		}
	}
}

int main()
{
	HideCursor();

	const Point dimensions = Dimensions();
	const int half_width = dimensions.x / 2, half_height = dimensions.y / 2;

	SplashScreen(half_width);

	for (int y = 0; y < dimensions.y; y++) {
		for (int x = 0; x < dimensions.x; x++) {
			std::cout << " ";
		}
		std::cout << std::endl;
	}

	bool alive = true;
	std::vector<Point> snake = { Point(half_width / 2, half_height) };
	Point apple(half_width + half_width / 2, half_height);
	int score = 0;

	std::thread input_thread = std::thread(input_loop);

	while (true) {
		// SCORE
		if (!alive) {
			// clear the screen
			RepositionCursor();
			for (int y = 0; y < dimensions.y; y++) {
				for (int x = 0; x < dimensions.x; x++) {
					std::cout << " ";
				}
				std::cout << std::endl;
			}

			ScoreScreen(score, half_width, half_height);

			// reset snake
			snake[0].x = half_width / 2;
			snake[0].y = half_height;

			while (snake.size() > 1) {
				snake.pop_back();
			}

			// reset apple
			apple.x = half_width + half_width / 2;
			apple.y = half_height;

			// reset game state
			alive = true;

			// clear the screen
			RepositionCursor();
			for (int y = 0; y < dimensions.y; y++) {
				for (int x = 0; x < dimensions.x; x++) {
					std::cout << " ";
				}
				std::cout << std::endl;
			}
		}

		// UPDATE

		// move the snake body
		for (int i = score; i > 0; i--) {
			snake[i] = snake[i - 1];
		}
		// move the snake head
		prev_dir = dir;
		switch (dir) {
		case UP:
			snake[0].y--;
			break;
		case DOWN:
			snake[0].y++;
			break;
		case LEFT:
			snake[0].x--;
			break;
		case RIGHT:
			snake[0].x++;
			break;
		default:
			break;
		}
		// snake dies if it goes out of bounds
		if (snake[0].x < 0 || snake[0].x >= dimensions.x ||
			snake[0].y < 0 || snake[0].y >= dimensions.y) {
			alive = false;
			// go back to the top of the loop
			continue;
		}
		// snake dies if it hits itself
		for (int i = 1; i <= score; i++) {
			if (snake[0].x == snake[i].x && snake[0].y == snake[i].y) {
				alive = false;
				continue;
			}
		}
		// if apple is eaten
		if (snake[0].x == apple.x && snake[0].y == apple.y) {
			// grow the snake
			snake.push_back(snake[score]);
			// increase the score
			score++;
			// randomise the apple's position
			apple.x = rand() % dimensions.x;
			apple.y = rand() % (dimensions.y - 1) + 1;
		}

		// RENDER

		// move the cursor to the start (instead of clearing)
		RepositionCursor();
		// print score
		std::cout << "Score: " << score << std::endl;
		// loop through each position
		for (int y = 1; y < dimensions.y; y++) {
			for (int x = 0; x < dimensions.x; x++) {
				if (apple.x == x && apple.y == y) {
					std::cout << "*";
				}
				else if (snake[0].x == x && snake[0].y == y) {
					std::cout << "O";
				} else {
					// yeah this part is pretty slow :shrug: but it works...
					bool was_snake = false;
					for (int i = 1; i <= score; i++) {
						if (snake[i].x == x && snake[i].y == y) {
							std::cout << "o";
							was_snake = true;
							break;
						}
					}
					if (!was_snake) {
						std::cout << ".";
					}
				}
			}
		}
		std::cout.flush();

		// DELAY
		sleep(50);
	}
	return 0;
}
