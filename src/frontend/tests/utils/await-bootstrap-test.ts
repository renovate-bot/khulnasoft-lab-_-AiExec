import { Page } from "playwright/test";
import { addFlowToTestOnEmptyAiexec } from "./add-flow-to-test-on-empty-aiexec";

export const awaitBootstrapTest = async (
  page: Page,
  options?: {
    skipGoto?: boolean;
    skipModal?: boolean;
  },
) => {
  if (!options?.skipGoto) {
    await page.goto("/");
  }

  await page.waitForSelector('[data-testid="mainpage_title"]', {
    timeout: 30000,
  });

  const countEmptyButton = await page
    .getByTestId("new_project_btn_empty_page")
    .count();
  if (countEmptyButton > 0) {
    await addFlowToTestOnEmptyAiexec(page);
  }

  await page.waitForSelector('[id="new-project-btn"]', {
    timeout: 30000,
  });

  if (!options?.skipModal) {
    let modalCount = 0;
    try {
      const modalTitleElement = await page?.getByTestId("modal-title");
      if (modalTitleElement) {
        modalCount = await modalTitleElement.count();
      }
    } catch (error) {
      modalCount = 0;
    }

    while (modalCount === 0) {
      await page.getByText("New Flow", { exact: true }).click();
      await page.waitForSelector('[data-testid="modal-title"]', {
        timeout: 3000,
      });
      modalCount = await page.getByTestId("modal-title")?.count();
    }
  }
};
